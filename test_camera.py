import cv2

for i in range(100):
    video = cv2.VideoCapture(i - 50)
    if video.isOpened():
        print(f"Camera found at device {i}")
        video.release()
