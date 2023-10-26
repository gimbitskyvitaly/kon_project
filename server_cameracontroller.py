import socket
import numpy as np
import time
import pickle
import pyautogui
import cv2

from controller import camera_controller, controller

localIP = "127.0.0.1"

localPort = 20001

bufferSize = 1024

msgFromServer = "Start camera controller"

bytesToSend = str.encode(msgFromServer)

# Create a datagram socket

UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

# Bind to address and ip

UDPServerSocket.bind((localIP, localPort))

print("UDP camera controller server up and listening")

# Listen for incoming datagrams

def server_rec_send():
    for i in np.arange(-1000, 1000):
        video = cv2.VideoCapture(i)
        ret, frame = video.read()
        if ret:
            priny('camera index', i)
            break
    video.set(3, 640)
    video.set(4, 480)
    video.set(10, 100)
    ret, frame = video.read()
    print(ret, frame)
    print('start camera')
    c_contr = camera_controller(video)
    pyautogui.FAILSAFE = False
    print(video.isOpened())

    start_writing = False
    address = None
    while (True):
        bytesAddressPair = UDPServerSocket.recvfrom(bufferSize)
        message = bytesAddressPair[0]

        address = bytesAddressPair[1]
        message = message.decode("utf-8")
        print(address, message)
        print(video)
        ret, frame = video.read()

        if not ret:
            print('error camera')
            break

        p_x, p_y = c_contr.process_camera(frame)
        bytesToSend = str(p_x) + ' ' + str(p_y)
        UDPServerSocket.sendto(bytesToSend.encode('utf-8'), address)

server_rec_send()
