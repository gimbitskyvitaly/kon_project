import socket
import numpy as np
import time
import pickle
import pyautogui
import cv2

from controller import controller

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
    # video = cv2.VideoCapture(0)
    # ret, frame = video.read()
    # print(ret, frame)
    print('start camera')
    contr = controller()
    pyautogui.FAILSAFE = False
    #print(video.isOpened())

    start_writing = False
    address = None
    while (True):
        bytesAddressPair = UDPServerSocket.recvfrom(bufferSize)
        message = bytesAddressPair[0]

        address = bytesAddressPair[1]
        message = message.decode("utf-8")
        print(address, message)
        #print(video)
        #ret, frame = video.read()

        # if not ret:
        #     print('error camera')
        #     break

        coord, gest = contr.controller_iteration()
        print('controller', gest)
        bytesToSend = str(coord) + ' ' + str(gest)
        UDPServerSocket.sendto(bytesToSend.encode('utf-8'), address)

server_rec_send()
