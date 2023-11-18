extends BasicPlayer

var spell_list = []
var branch_list = {"destruction": 0, "recovery": 0, "summon": 0, "illusion": 0}
var element_list = {"air": 0, "fire": 0, "water": 0, "earth": 0}

var camera_controller_on = false
var serverIP = "127.0.0.1"
var serverPort = 20001
var bufferSize = 1024
var UDPClientSocket = PacketPeerUDP.new()

func _init():
	speed = 1
	start_speed = 1
	
	UDPClientSocket.set_dest_address(serverIP, serverPort)
	UDPClientSocket.connect_to_host(serverIP, serverPort)

	
func _physics_process(delta):
	check_get_shield()
	if Input.is_mouse_button_pressed(1): # when click Left mouse button
		target = get_global_mouse_position()
	if camera_controller_on:
		var res_message = controller()
		if res_message:
			var gest_list = []
			if res_message['gest']:
				gest_list = res_message['gest']
				print(gest_list)
			var alpha_x = 1000000
			var alpha_y = 2000000
			var min_r = 0.0
			var dir_x = res_message['x_coord']
			var dir_y = res_message['y_coord']
			var r = sqrt(dir_x**2 + dir_y**2)
			if r < min_r:
				dir_x = 0
				dir_y = 0
			target = global_position + Vector2(alpha_x * dir_x, alpha_y * dir_y)
	going (target, speed_up_target)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_S:
			camera_controller_on = not camera_controller_on
		if event.keycode == KEY_ENTER:
			check_spell_list()
		spell_list.append(event.keycode - 48)
		if event.keycode - 48 >= 1 and event.keycode - 48 <= 4:
			shield_branch = event.keycode - 48
		if shield_branch >= 1 and shield_branch <= 4:
			shield(spell_scale)
		if event.keycode == KEY_W:
			invise()
		if event.keycode == KEY_E:
			#speed_up_target = get_global_mouse_position()
			speed_up(get_global_mouse_position())	
		if event.keycode == KEY_R:
			shoot(get_global_mouse_position(), spell_scale)
		if event.keycode == KEY_T:
			call_mob(get_global_mouse_position(), spell_scale * rng.randf_range(0.5, 1))
			
func check_spell_list ():
	for i in spell_list:
		if i == 17:###############'20'
			branch_list["destruction"] += 1
		if i == 18:
			branch_list["recovery"] += 1
		if i == 19:
			branch_list["summon"] += 1
		if i == 20:
			branch_list["illusion"] += 1
		if i == int('1'):
			element_list['air'] += 1
		if i == int('2'):
			element_list['fire'] += 1
		if i == int('3'):
			element_list['water'] += 1
		if i == int('4'):
			element_list['earth'] += 1
	print (branch_list, element_list)
	spell_list = []
			
			
func going (target, speed_up_target):
	if target == null:
		return
	if speed_up_target != null:
		target = speed_up_target
	v = global_position.direction_to(target)
	if global_position.distance_to(target) < 15:
			v = Vector2.ZERO
	attack (15)			
	ind = round(4*(v.angle()/PI))+ 4
	if ind > 7:
		ind = 0
	if global_position.distance_to(target) >= 15:
		is_going = true
		velocity = v * speed
	else:
		$AnimationPlayer.play ("attack_" + "down")
		return
	if is_speed_up == true:
		#v = global_position.direction_to(speed_up_target)
		velocity *= 5
	velocity += v * add_v
	animate_going(ind)
	move_and_collide(velocity)
	
	
func controller():
	var message = "camera_controller".to_ascii_buffer()
	UDPClientSocket.put_packet(message)
	var bytesAddressPair = UDPClientSocket.get_packet()
	var receivedMessage = bytesAddressPair.get_string_from_utf8()
	var coord_gest_dict = str_to_var(receivedMessage)
	if coord_gest_dict:
		return coord_gest_dict
	return null
	
	


