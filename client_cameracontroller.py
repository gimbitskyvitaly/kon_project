import socket
import numpy as np

serverIP = "127.0.0.1"

serverPort = 20001

bufferSize = 1024

UDPClientSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

start_camera_controller = False

def key_press(start_camera_controller):
    if not start_camera_controller:
        start_camera_controller = True
    else:
        start_camera_controller = False
    return start_camera_controller

i = 0
while True:
    i += 1
    print(i)
    if i % 1000000 == 1000000 - 1:
        start_camera_controller = key_press(start_camera_controller)
    if start_camera_controller:
        message = b'camera_controller'
        UDPClientSocket.sendto(message, (serverIP, serverPort))
        bytesAddressPair = UDPClientSocket.recvfrom(bufferSize)
        message = bytesAddressPair[0]

        address = bytesAddressPair[1]
        message = message.decode("utf-8")
        print(message)

