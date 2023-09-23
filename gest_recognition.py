import os
import cv2
import csv
import numpy as np
import mediapipe as mp
from catboost import CatBoostClassifier

hands = mp.solutions.hands.Hands(static_image_mode=False, max_num_hands=2, min_detection_confidence=0.5)

model_dir = 'gest_model'
model = CatBoostClassifier()
model.load_model(model_dir)

gests = ['fire', 'water', 'stone', 'wind', 'kon']

video = cv2.VideoCapture(0)

frames = np.zeros((3, 126))

count = 0
data = np.zeros((42, 3))

while True:
    ret, frame = video.read()
    if not ret:
        break

    image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = hands.process(image)
    landmarks = results.multi_hand_landmarks
    count_landmarks = 0
    if landmarks:
        for landmark in landmarks:
            for coordinates in landmark.landmark:
                if count_landmarks < 42:
                    data[count_landmarks] = np.array([coordinates.x, coordinates.y, coordinates.z])
                count_landmarks += 1
                if count_landmarks == 42:
                    break

        frames[0] = frames[1]
        frames[1] = frames[2]
        frames[2] = data.flatten()
        if count >= 2:
            y = model.predict(frames.reshape(1, -1))
            gest = gests[y[0, 0]]
            os.system('clear')
            print(gest)

        count += 1
