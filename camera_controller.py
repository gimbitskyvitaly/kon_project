import cv2
import mediapipe as mp
import pyautogui
import os
import numpy as np
from skimage.measure import block_reduce
count = 0
cam = cv2.VideoCapture(0)
face_mesh = mp.solutions.face_mesh.FaceMesh(refine_landmarks=True)
screen_w, screen_h = pyautogui.size()
first_f = True
x_f = 0
y_f = 0
while True:
    _, frame = cam.read()
    frame = cv2.flip(frame, 1)
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    output = face_mesh.process(rgb_frame)
    landmark_points = output.multi_face_landmarks
    # frame_h, frame_w, _ = frame.shape
    if landmark_points:
        landmarks = landmark_points[0].landmark
        landmark = landmarks[474:478][1]
        # for id, landmark in enumerate(landmarks[474:478]):
        #     # x = int(landmark.x * frame_w)
        #     # y = int(landmark.y * frame_h)
        #     # cv2.circle(frame, (x, y), 3, (0, 255, 0))
        #     if id == 1:

        if first_f:
            x_f = landmark.x
            y_f = landmark.y
            first_f = False

        screen_x = screen_w * landmark.x
        screen_y = screen_h * landmark.y
        # print(landmark.x, landmark.y)
        pyautogui.moveTo(screen_x, screen_y)
        os.system('clear')
        print(landmark.x - x_f, landmark.y - y_f)
        # left = [landmarks[145], landmarks[159]]
        # for landmark in left:
        #     x = int(landmark.x * frame_w)
        #     y = int(landmark.y * frame_h)
        #     # cv2.circle(frame, (x, y), 3, (0, 255, 255))
        # # print(left[0].y - left[1].y)
        # if (left[0].y - left[1].y) < 0.021:
        #     pyautogui.click()
        #     pyautogui.sleep(1)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

    # if count % 100 == 0:
    #     cv2.imshow('Eye Controlled Mouse', frame)
    count += 1
    cv2.waitKey(1)
