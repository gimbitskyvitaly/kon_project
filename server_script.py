import socket
import numpy as np
import time
import pickle

from gesture_control import Gesture_Control

localIP = "127.0.0.1"

localPort = 20001

bufferSize = 1024

msgFromServer = "Hello UDP Client"

bytesToSend = str.encode(msgFromServer)

# Create a datagram socket

UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

# Bind to address and ip

UDPServerSocket.bind((localIP, localPort))

print("UDP server up and listening")

# Listen for incoming datagrams

g_c = Gesture_Control(model = pickle.load(open("pima.pickle.dat", "rb")))

start_writing = False
adress = None
while (True):
    if start_writing == False:
        bytesAddressPair = UDPServerSocket.recvfrom(bufferSize)
        message = bytesAddressPair[0]

        address = bytesAddressPair[1]
        g_c.default()
    if message != None:
        start_writing = True
    if start_writing == False:
        continue
    end_of_geasture = False
    bytesToSend = g_c.pred_label()
    if bytesToSend != -1:
        end_of_geasture = g_c.list_of_labels(bytesToSend)###############################too quick
    else:
        if len(g_c.labels) > 0:
            end_of_geasture = True
    bytesToSend = g_c.labels
    bytesToSend = str(bytesToSend).encode("utf-8")

    # Sending a reply to client
    if end_of_geasture == True:
        UDPServerSocket.sendto(bytesToSend, address)######################always send
        g_c.default()
        print (bytesToSend)
        start_writing = False