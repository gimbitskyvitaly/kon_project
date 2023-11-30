import os
import cv2
import pyautogui
import csv
import numpy as np
from collections import Counter
import copy
import mediapipe as mp
from catboost import CatBoostClassifier
import pickle
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import LinearSVC


def centrolise_array(x):
    x = x.reshape(-1, 3)
    mean = np.mean(x, axis= 0)
    mean = np.array([mean] * len(x))
    x -= mean
    x = x.flatten()
    return x


def count_gest_list(gest_list):
    result_list = []
    if len(gest_list) == 0:
        return result_list
    count_gest = 1
    min_count = 2
    for i in np.arange(1, len(gest_list)):
        gest = gest_list[i]
        if gest == gest_list[i - 1]:
            count_gest += 1
            if count_gest == min_count and (len(result_list) == 0 or result_list[-1] != gest):
                result_list.append(gest)
        else:
            count_gest = 1

    return result_list


class gest_controller():
    def __init__(self, video, classifier= 'catboost', centrolise= True):
        self.hands = mp.solutions.hands.Hands(static_image_mode=False, max_num_hands=2, min_detection_confidence=0.5)
        self.classifier = classifier
        self.centrolise = centrolise

        if classifier == 'catboost':
            self.model_dir = 'gest_model'
            self.two_hands_model_dir = 'two_hands_gest_model'
            self.model = CatBoostClassifier()
            self.model.load_model(self.model_dir)
            self.two_hands_model = CatBoostClassifier()
            self.two_hands_model.load_model(self.two_hands_model_dir)

        if classifier == 'knn':
            if centrolise:
                self.model_dir = 'one_hand_model_centrolised_knn'
                self.two_hands_model_dir = 'two_hands_gest_model_centrolised_knn'
            else:
                self.model_dir = 'one_hand_model_knn'
                self.two_hands_model_dir = 'two_hands_gest_model_knn'
            self.model = KNeighborsClassifier()
            self.model = pickle.load(open(self.model_dir, 'rb'))
            self.two_hands_model = KNeighborsClassifier()
            self.two_hands_model = pickle.load(open(self.two_hands_model_dir, 'rb'))

        if classifier == 'svm':
            if centrolise:
                self.model_dir = 'one_hand_model_centrolised_svm'
                self.two_hands_model_dir = 'two_hands_gest_model_centrolised_svm'
            else:
                self.model_dir = 'one_hand_model_svm'
                self.two_hands_model_dir = 'two_hands_gest_model_svm'
            self.model = LinearSVC()
            self.model = pickle.load(open(self.model_dir, 'rb'))
            self.two_hands_model = LinearSVC()
            self.two_hands_model = pickle.load(open(self.two_hands_model_dir, 'rb'))

        self.video = video

        self.gest_list = []
        self.prev_gest = [None] * 4

        self.gests = ['reconstruction', 'illusion', 'destruction', 'kon', 'stop', 'unk']
        self.two_hands_gests = ['fire', 'water', 'stone', 'wind', 'stop', 'unk']

        self.frame = np.zeros(126)

        self.count = 0
        self.data = np.zeros((42, 3))

    def replace_subarrays(self, target_value):
        array = self.gest_list
        print(self.gest_list)
        result = []
        subarray = []
        for value in array:
            if value == target_value or value == 'stop':
                subarray.append(value)
            elif subarray:
                #result.extend([target_value] * len(subarray))
                if len(subarray) >= 3:
                    result.append('space')
                subarray = []
                result.append(value)
            else:
                result.append(value)
        print(result)

        return result

    def parse_gest(self):
        begin_iter = 0
        parse_list = []
        print('input_list', self.gest_list)
        self.gest_list = self.replace_subarrays('unk')
        parse_list = count_gest_list(self.gest_list)
        self.gest_list = []
        print('parse', parse_list)
        # for i in np.arange(len(self.gest_list) - 2):
        #     if self.gest_list[i] == 'space' and i > begin_iter:
        #         count = Counter(self.gest_list[begin_iter:i])
        #         gest = count.most_common()[0][0]
        #         parse_list.append(gest)
        #         begin_iter = i + 1
        # if len(parse_list) == 0 and len(self.gest_list) > 3:
        #     count = Counter(self.gest_list[:-3])
        #     print(count.most_common())
        #     gest = count.most_common()[0][0]
        #     parse_list.append(gest)
        # self.gest_list = []
        return parse_list

    def process_gest(self, frame):
        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.hands.process(image)
        landmarks = results.multi_hand_landmarks
        count_landmarks = 0
        if landmarks:
            for landmark in landmarks:
                for coordinates in landmark.landmark:
                    if count_landmarks < 42:
                        self.data[count_landmarks] = np.array([coordinates.x, coordinates.y, coordinates.z])
                    count_landmarks += 1
                    if count_landmarks == 42:
                        break

            self.frame = self.data.flatten()
            if self.centrolise:
                self.frame = centrolise_array(self.frame)
            if self.classifier != 'catboost':
                self.frame = np.array([self.frame])
            if len(landmarks) == 1:
                # frame = self.frame.reshape(-1, 3)
                # frame -= frame[0]
                # frame = frame.flatten()
                y = self.model.predict(self.frame)
                #print(self.model.predict_proba(self.frame))
                gest = self.gests[y[0]]
            else:
                y = self.two_hands_model.predict(self.frame)
                gest = self.two_hands_gests[y[0]]
        else:
            gest = 'unk'
        self.gest_list.append(gest)
        for i in np.arange(len(self.prev_gest) - 1):
            self.prev_gest[i] = self.prev_gest[i + 1]
        self.prev_gest[len(self.prev_gest) - 1] = gest
        if self.prev_gest == ['stop'] * 4 or (self.gest_list[-1] != 'unk' and self.prev_gest == [self.gest_list[-1]] * 4):
            return self.parse_gest()

            # return gest

class camera_controller():
    def __init__(self, video):
        self.face_mesh = mp.solutions.face_mesh.FaceMesh(refine_landmarks=True)
        self.screen_w, self.screen_h = pyautogui.size()

        self.video = video

        self.first_f = True
        self.x_f = np.zeros(25)
        self.y_f = np.zeros(25)

        self.x_s = np.zeros(25)
        self.y_s = np.zeros(25)


    def centrolise_camera(self):
        self.first_f = True

    def process_camera(self, frame):
        frame = cv2.flip(frame, 1)
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        output = self.face_mesh.process(rgb_frame)
        landmark_points = output.multi_face_landmarks
        if landmark_points:
            for face_landmarks in landmark_points:
                for i, landmarkxy in enumerate(face_landmarks.landmark[::20]):
                    self.x_s[i] = landmarkxy.x
                    self.y_s[i] = landmarkxy.y
            landmarks = landmark_points[0].landmark
            landmark = landmarks[474:478][1]
            if landmark and landmark.x and landmark.y:

                if self.first_f:
                    # print(self.x_f)
                    # print(self.y_f)
                    self.x_f = copy.deepcopy(self.x_s)
                    self.y_f = copy.deepcopy(self.y_s)

                screen_x = self.screen_w * landmark.x
                screen_y = self.screen_h * landmark.y
                if self.first_f:
                    self.first_f = False
                    return 0, 0


                #pyautogui.moveTo(screen_x, screen_y)

            else:
                return 0, 0

        # if cv2.waitKey(1) & 0xFF == ord('q'):
        #     break

            cv2.waitKey(1)
            return np.mean(self.x_s - self.x_f), np.mean(self.y_s - self.y_f)

        cv2.waitKey(1)

        return 0, 0

class controller():
    def __init__(self, classifier= 'catboost', centrolise= False):
        self.video = cv2.VideoCapture(0)

        self.gest_contr = gest_controller(self.video, classifier, centrolise)
        self.camera_contr = camera_controller(self.video)

        pyautogui.FAILSAFE = False


    def centrolise_camera(self):
        self.camera_contr.centrolise_camera()

    def controller_iteration(self):
        ret, frame = self.video.read()

        if not ret:
            return 0

        gest = self.gest_contr.process_gest(frame)
        p_x, p_y = self.camera_contr.process_camera(frame)
        #os.system('clear')
        if gest:
            print(p_x, p_y)
            print(gest)
        return [p_x, p_y], gest

# contr = controller()
#
# while True:
#     contr.controller_iteration()
