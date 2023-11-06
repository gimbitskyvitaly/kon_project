import cv2
import csv
import numpy as np
import mediapipe as mp
import sys

hands = mp.solutions.hands.Hands(static_image_mode=False, max_num_hands=2, min_detection_confidence=0.5)

video = cv2.VideoCapture(0)

num_frames = 1000
frames_gest = 5
output_folder = 'dataset'

def write_dataset(gest):
    file = open(output_folder + '/' + 'gest_' + gest + '.csv', 'w')
    writer = csv.writer(file)

    count = 0
    frames_list = []
    data = np.zeros((42, 3))

    while count < num_frames:
        ret, frame = video.read()
        if not ret:
            break

        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = hands.process(image)
        landmarks = results.multi_hand_landmarks
        count_landmarks = 0
        if landmarks and len(landmarks) == 2:
            for landmark in landmarks:
                for coordinates in landmark.landmark:
                    data[count_landmarks] = np.array([coordinates.x, coordinates.y, coordinates.z])
                    count_landmarks += 1

            print(data.shape)
            writer.writerow(data.flatten())

            count += 1

def main():
    gest = sys.argv[1]
    print(gest)
    write_dataset(gest)

main()

