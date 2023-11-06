extends Node

var serverIP = "127.0.0.1"
var serverPort = 20001
var bufferSize = 1024
var UDPClientSocket = UDPSocket.new()

var start_camera_controller = false

func _ready():
    UDPClientSocket.open()
    start_camera_controller = false

func _process(delta):
    var i = 0
    i += 1
    print(i)
    if i % 1000000 == 1000000 - 1:
        start_camera_controller = key_press(start_camera_controller)
    if start_camera_controller:
        var message = "camera_controller".to_ascii()
        UDPClientSocket.send_to(message, serverIP, serverPort)
        var bytesAddressPair = UDPClientSocket.recv_from(bufferSize)
        var receivedMessage = bytesAddressPair[0].get_string_from_ascii()
        var address = bytesAddressPair[1]
        print(receivedMessage)

func key_press(start_camera_controller):
    if not start_camera_controller:
        start_camera_controller = true
    else:
        start_camera_controller = false
    return start_camera_controller
