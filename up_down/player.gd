extends BasicPlayer

func _init():
	speed = 1
	start_speed = 1

	
func _physics_process(delta):
	check_get_shield()
	if Input.is_mouse_button_pressed(1): # when click Left mouse button
		target = get_global_mouse_position()
	going (target, speed_up_target)

func _input(event):
	if event is InputEventKey and event.pressed:
		shield_branch = event.keycode - 48
		if shield_branch >= 1 and shield_branch <= 4:
			shield()
		print (shield_branch)
		if event.keycode == KEY_W:
			invise()
		if event.keycode == KEY_E:
			speed_up(get_global_mouse_position())	
		if event.keycode == KEY_R:
			shoot(get_global_mouse_position())
			
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
	
	


