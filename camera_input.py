import cv2
import mediapipe as mp

# Инициализация руководителя MediaPipe
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=False, max_num_hands=2, min_detection_confidence=0.5)

# Захват видеопотока с веб-камеры
cap = cv2.VideoCapture(0)

while cap.isOpened():
    success, image = cap.read()
    if not success:
        print("Не удалось получить кадр с веб-камеры.")
        break

    # Перевод цветового пространства BGR в RGB
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    # Обнаружение рук на изображении
    results = hands.process(image_rgb)

    # Распознавание жестов
    count = 0
    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            # Отображение ключевых точек руки
            for landmark in hand_landmarks.landmark:
                x = int(landmark.x * image.shape[1])
                y = int(landmark.y * image.shape[0])
                cv2.circle(image, (x, y), 5, (0, 255, 0), -1)
                count += 1

    print('Количество точек', count)

    # Отображение изображения с рукой и ключевыми точками
    cv2.imshow('Hand Gestures', image)
    if cv2.waitKey(10) & 0xFF == ord('q'):
        break

# Освобождение ресурсов
cap.release()
cv2.destroyAllWindows()
