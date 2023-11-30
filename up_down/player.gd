extends BasicPlayer

var camera_controller_on = false
var serverIP = "127.0.0.1"
var serverPort = 20001
var bufferSize = 1024
var UDPClientSocket = PacketPeerUDP.new()

var shooting_tween

func _init():
	speed = 1
	start_speed = 1

	UDPClientSocket.set_dest_address(serverIP, serverPort)
	UDPClientSocket.connect_to_host(serverIP, serverPort)

func fire_to_closest():
	var closest_body = find_closest_in_group('Player')
	print(closest_body)
	wizard.cast_spell('missile', 'fire', {
		'target': closest_body.global_position,
		'caster': self,
		'scene': get_tree().root
		}
	)

func _physics_process(delta):
	print('pos', global_position)
	speed = 1
	start_speed = 1
	check_get_shield()
	if Input.is_mouse_button_pressed(1): # when click Left mouse button
		target = get_global_mouse_position()
	if camera_controller_on:
		var res_message = controller()
		if res_message:
			var gest_list = []
			if res_message['gest']:
				gest_list = res_message['gest']
				spell_with_gest(gest_list)
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
	going(target, speed_up_target)

func _input(event):
	var wizard = get_tree().root.get_node("World/Wizard")
	var shield_overlapping_bodies = $Area_Shield.get_overlapping_bodies()
	shield_overlapping_bodies.erase(self)
	for body in shield_overlapping_bodies:
		if !body.is_in_group('Player'):
			shield_overlapping_bodies.erase(body)
	
	var params = {
		'shield': {
			'shape': $Area_Shield/Shield, 
			'sprite': $Area_Shield/Sprite2D,
			'bodies': shield_overlapping_bodies
		}, 
		'missile': {
			'target': get_global_mouse_position(),
			'caster': self,
			'scene': get_tree().root
		}
	}
	var missile_circle_params = []
	var missiles_count = 15
	for i in range(missiles_count):
		var angle = 2 * PI * i / missiles_count
		var curr_target = global_position + Vector2(cos(angle), sin(angle))
		missile_circle_params.append({
			'target': curr_target,
			'caster': self,
			'scene': get_tree().root}
		)
	var missiles_delays = []
	for i in range(missiles_count):
		var curr_delay = i * 0.03
		missiles_delays.append(curr_delay)
		
	
	if event is InputEventKey and event.pressed:
#		shield_branch = event.keycode - 48
#		if shield_branch >= 1 and shield_branch <= 4:
#			shield()
#		print (shield_branch)
		if event.keycode == KEY_S:
#			if not camera_controller_on:
#				shooting_tween = create_tween().set_loops()
#				shooting_tween.tween_callback(fire_to_closest).set_delay(1)
#			else:
#				shooting_tween.kill()
			camera_controller_on = not camera_controller_on
		var elements_box = get_tree().root.get_node("World").get_node('CanvasLayer').get_node('Elements')
		if event.keycode == KEY_1:
			var icon = elements_box.get_node('Water')
			icon.visible = !icon.visible
			if elements.has('water'):
				elements.erase('water')
			else:
				elements.append('water')
		if event.keycode == KEY_2:
			var icon = elements_box.get_node('Fire')
			icon.visible = !icon.visible			
			if elements.has('fire'):
				elements.erase('fire')
			else:
				elements.append('fire')
		if event.keycode == KEY_3:
			var icon = elements_box.get_node('Air')
			icon.visible = !icon.visible	
			if 'air' in elements:
				elements.erase('air')
			else:
				elements.append('air')
		if event.keycode == KEY_4:
			var icon = elements_box.get_node('Earth')
			icon.visible = !icon.visible	
			if 'earth' in elements:
				elements.erase('earth')
			else:
				elements.append('earth')
		if event.keycode == KEY_V:
			var icon = elements_box.get_node('Shield')
			icon.visible = !icon.visible	
			elements_box.get_node('Missile').visible = false
			next_spell = 'shield'
		if event.keycode == KEY_B:
			var icon = elements_box.get_node('Missile')
			icon.visible = !icon.visible	
			elements_box.get_node('Shield').visible = false
			next_spell = 'missile'
		if event.keycode == KEY_SPACE:
#			var missile_icon = elements_box.get_node('Missile')
#			missile_icon.visible = false
#			var shield_icon = elements_box.get_node('Shield')
#			shield_icon.visible = false
			print(next_spell, elements)
			for element in elements:
				wizard.cast_spell(next_spell, element, params[next_spell])
#			next_spell = null
#			elements = []

			
		if event.keycode == KEY_W:
			invise()
		if event.keycode == KEY_E:
			speed_up(get_global_mouse_position())	
		if event.keycode == KEY_R:
			wizard.cast_spell('missile', 'fire', params['missile'])
		if event.keycode == KEY_T:
			wizard.cast_spell('missile', 'air', params['missile'])
		if event.keycode == KEY_Y:
			wizard.cast_spell('missile', 'water', params['missile'])
		if event.keycode == KEY_Z:
			wizard.cast_spell('shield', 'fire', params['shield'])
		if event.keycode == KEY_X:
			wizard.cast_spell('shield', 'air', params['shield'])
		if event.keycode == KEY_C:
#			$Sprite2Dtest.visible = !$Sprite2Dtest.visible			
			wizard.cast_spell('shield', 'water', params['shield'])
		if event.keycode == KEY_J:
			$AnimatedFoxJump.show()
			$FoxPlayer.play('fox_jump')
			is_casting_cirle = true
			create_tween().tween_callback(
					func(): is_casting_cirle = false
				).set_delay(missiles_delays.max())
			for i in range(missiles_count):
				create_tween().tween_callback(
						func(): wizard.cast_spell(
							'missile', 'fire', missile_circle_params[i]
							)
					).set_delay(missiles_delays[i])
#				wizard.cast_spell('missile', 'fire', missile_param)
#			is_casting_cirle = false
		if event.keycode == KEY_A:		
			create_mob(get_global_mouse_position())
			
		
func going (target, speed_up_target):
	if is_casting_cirle:
		return
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
		v = global_position.direction_to(speed_up_target)
		velocity *= 5
	velocity += v * add_v
	animate_going(ind)
	move_and_collide(velocity)


func spell_with_gest(gest_list):
	var branch = null
	var element = null
	var wizard = get_tree().root.get_node("World/Wizard")
	var shield_overlapping_bodies = $Area_Shield.get_overlapping_bodies()
	shield_overlapping_bodies.erase(self)
	var closest_body = find_closest_in_group('Player')
	for body in shield_overlapping_bodies:
		if !body.is_in_group('Player'):
			shield_overlapping_bodies.erase(body)

	var params = {
		'shield': {
			'shape': $Area_Shield/Shield,
			'sprite': $Area_Shield/Sprite2D,
			'bodies': shield_overlapping_bodies
		},
		'missile': {
			'target': closest_body.global_position,
			'caster': self,
			'scene': get_tree().root
		}
	}
	if 'reconstruction' in gest_list:
		branch = 'reconstruction'
	if 'illusion' in gest_list:
		branch = 'illusion'
		invise()
	if 'kon' in gest_list:
		branch = 'kon'
		create_mob(get_global_mouse_position())
	if 'destruction' in gest_list:
		branch = 'destruction'
	if 'wind' in gest_list:
		element = 'air'
	if 'water' in gest_list:
		element = 'water'
	if 'stone' in gest_list:
		element = 'water'
	if 'fire' in gest_list:
		element = 'fire'

	if not branch:
		branch = 'destruction'

	if branch == 'destruction':
		if not element:
			element = 'fire'
		wizard.cast_spell('missile', element, params['missile'])
		return
	if branch == 'reconstruction':
		if not element:
			element = 'water'
		wizard.cast_spell('shield', element, params['shield'])
		return


func controller():
	var message = "camera_controller".to_ascii_buffer()
	UDPClientSocket.put_packet(message)
	var bytesAddressPair = UDPClientSocket.get_packet()
	var receivedMessage = bytesAddressPair.get_string_from_utf8()
	var coord_gest_dict = str_to_var(receivedMessage)
	if coord_gest_dict:
		return coord_gest_dict
	return null



func _on_fox_player_animation_started(anim_name):
	print('STARTED')
	create_tween().tween_property($AnimatedFoxJump, "scale", Vector2(7, 7), 0.2)
	create_tween().tween_property($AnimatedFoxJump, "modulate:a", 0, 0.35).set_delay(0.15)
	
	$AnimatedFoxJump.scale = Vector2(1, 1)
	$AnimatedFoxJump.modulate = Color.WHITE
	
