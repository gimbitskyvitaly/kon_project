import os
import cv2
import pyautogui
import csv
import numpy as np
from collections import Counter
import mediapipe as mp
from catboost import CatBoostClassifier

class gest_controller():
    def __init__(self, video):
        self.hands = mp.solutions.hands.Hands(static_image_mode=False, max_num_hands=2, min_detection_confidence=0.5)

        self.model_dir = 'gest_model'
        self.two_hands_model_dir = 'gest_model'
        self.model = CatBoostClassifier()
        self.model.load_model(self.model_dir)
        self.two_hands_model = CatBoostClassifier()
        self.two_hands_model.load_model(self.two_hands_model_dir)

        self.video = video

        self.gest_list = []
        self.prev_gest = [None] * 3

        self.gests = ['reconstruction', 'illusion', 'destruction', 'kon', 'stop', 'unk']

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
        self.gest_list = self.replace_subarrays('unk')
        for i in np.arange(len(self.gest_list) - 2):
            if self.gest_list[i] == 'space':
                count = Counter(self.gest_list[begin_iter:i])
                gest = count.most_common()[0][0]
                parse_list.append(gest)
                begin_iter = i + 1
        if len(parse_list) == 0 and len(self.gest_list) > 3:
            count = Counter(self.gest_list[:-3])
            print(count.most_common())
            gest = count.most_common()[0][0]
            parse_list.append(gest)
        self.gest_list = []
        return parse_list

    def process_gest(self, frame):
        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.hands.process(image)
        landmarks = results.multi_hand_landmarks
        count_landmarks = 0
        if landmarks:
            if landmarks:
                for landmark in landmarks:
                    for coordinates in landmark.landmark:
                        if count_landmarks < 42:
                            self.data[count_landmarks] = np.array([coordinates.x, coordinates.y, coordinates.z])
                        count_landmarks += 1
                        if count_landmarks == 42:
                            break

                self.frame = self.data.flatten()
                if len(landmarks) == 1:
                    y = self.model.predict(self.frame)
                else:
                    y = self.two_hands_model.predict(self.frame)
                #print(self.model.predict_proba(self.frame))
                gest = self.gests[y[0]]
            self.gest_list.append(gest)
            for i in np.arange(len(self.prev_gest) - 1):
                self.prev_gest[i] = self.prev_gest[i + 1]
            self.prev_gest[len(self.prev_gest) - 1] = gest
            if self.prev_gest == ['stop'] * 3:
                return self.parse_gest()

            # return gest

class camera_controller():
    def __init__(self, video):
        self.face_mesh = mp.solutions.face_mesh.FaceMesh(refine_landmarks=True)
        self.screen_w, self.screen_h = pyautogui.size()

        self.video = video

        self.first_f = True
        self.x_f = 0
        self.y_f = 0

    def process_camera(self, frame):
        frame = cv2.flip(frame, 1)
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        output = self.face_mesh.process(rgb_frame)
        landmark_points = output.multi_face_landmarks
        if landmark_points:
            landmarks = landmark_points[0].landmark
            landmark = landmarks[474:478][1]
            if landmark and landmark.x and landmark.y:

                if self.first_f:
                    self.x_f = landmark.x
                    self.y_f = landmark.y

                screen_x = self.screen_w * landmark.x
                screen_y = self.screen_h * landmark.y
                if self.first_f:
                    self.first_f = False
                    return 0, 0


                pyautogui.moveTo(screen_x, screen_y)

            else:
                return 0, 0

        # if cv2.waitKey(1) & 0xFF == ord('q'):
        #     break

            cv2.waitKey(1)

            return landmark.x - self.x_f, landmark.y - self.y_f

        cv2.waitKey(1)

        return 0, 0

class controller():
    def __init__(self):
        self.video = cv2.VideoCapture(0)

        self.gest_contr = gest_controller(self.video)
        self.camera_contr = camera_controller(self.video)

        pyautogui.FAILSAFE = False

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
