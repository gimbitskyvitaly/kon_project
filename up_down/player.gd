extends BasicPlayer

func _init():
	speed = 1
	start_speed = 1

func _physics_process(delta):
	check_get_shield()
	if Input.is_mouse_button_pressed(1): # when click Left mouse button
		target = get_global_mouse_position()
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
	
	if event is InputEventKey and event.pressed:
#		shield_branch = event.keycode - 48
#		if shield_branch >= 1 and shield_branch <= 4:
#			shield()
#		print (shield_branch)
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
		v = global_position.direction_to(speed_up_target)
		velocity *= 5
	velocity += v * add_v
	animate_going(ind)
	move_and_collide(velocity)
	
	


