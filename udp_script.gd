extends Node

var udp := PacketPeerUDP.new()
var connected = false

func _ready():
	#OS.execute("python", ["python_script.py"])
	udp.set_dest_address("127.0.0.1", 20001)
	udp.connect_to_host("127.0.0.1", 20001)

func _process(delta):
	#udp.set_dest_address("127.0.0.1", 20001)
	#udp.put_packet("Time to stop".to_utf8())
	if udp.get_available_packet_count() > 0:
		print("got_pocket")
		print("Connected: %s" % udp.get_packet().get_string_from_utf8())


func _on_Button_button_down():
	udp.put_packet("Time to stop".to_utf8())
