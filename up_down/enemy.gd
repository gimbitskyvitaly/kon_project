extends BasicPlayer




var target_body = null
var i = 0
var target_bodies = []

func _init():
	speed = 0.1
	start_speed = 0.1
	
	
func _physics_process(delta):
	check_get_shield()
	if Input.is_mouse_button_pressed(1): # when click Left mouse button
		target = get_global_mouse_position()
		
		
	if target_body != null:
		if i % 100 == 0:
			speed_up(target_body.position)
		if i % 200 == 0 and target_body != null:
			shoot (target_body.get_global_position())
	going(target_body, speed_up_target)
	i += 1
	
func going(target, speed_up_target):
	if target != null:
		v = global_position.direction_to(target.global_position)
		attack (15)			
		ind = round(4*(v.angle()/PI))+ 4
		if ind > 7:
			ind = 0
		if global_position.distance_to(target.global_position) <= 1:
			v = 0
		velocity = v * speed
		if is_speed_up == true:
			#v = global_position.direction_to(target.position)
			velocity *= 5
		velocity += v * add_v
		animate_going(ind)
		move_and_collide(velocity)

func _on_area_folow_body_entered(body):
	if body.is_in_group("Player") and body.global_position != global_position:
		target_bodies.push_back (body)
		target_body = target_bodies[-1]


func _on_area_folow_body_exited(body):
	target_bodies.erase(body)
	if len(target_bodies) > 0:
		target_body = target_bodies[-1]
