extends BasicPlayer




var target_body = null
var i = 0
var target_bodies = []
var in_shield_bodies = []

func _init():
	speed = 0.1
	start_speed = 0.1
	hp = 20
	
	
func _physics_process(delta):
	check_get_shield()
	
	process_burn_damage()
	process_slowdown()
	process_throwback()
	
		
	if target_body != null:
		if i % 100 == 0:
			speed_up(target_body.position)
	going(target_body, speed_up_target)
	i += 1
		
	
func animate_going(ind):
	if is_going == true:
		$AnimationPlayer.play("stay_" + "down")
	
func going(target, speed_up_target):
	animate_going(-1)
	if target != null:
		v = global_position.direction_to(target.global_position)
		#attack (15)			
		ind = round(2*(v.angle()/PI))+ 2
		if ind > 3:
			ind = 0
		if global_position.distance_to(target.global_position) <= 1:
			v = 0
		velocity = v * speed
		if is_speed_up == true:
			#v = global_position.direction_to(target.position)
			velocity *= 5
		velocity += v * add_v
		move_and_collide(velocity)

func _on_area_folow_body_entered(body):
	if body.is_in_group("Player") and body.global_position != global_position and body.summoner != summoner:
		target_bodies.push_back (body)
		target_body = target_bodies[-1]


func _on_area_folow_body_exited(body):
	target_bodies.erase(body)
	if len(target_bodies) > 0:
		target_body = target_bodies[-1]
		
func _on_area_shield_body_entered(body):
	if body.is_in_group("Player") and body.global_position != global_position and body.summoner != summoner:
		body.is_geting_damage_shield["fire"] += rng.randf_range(0.4, 0.7)
		in_shield_bodies.push_back(body)
	if in_shield_bodies.is_empty() ==false:
		$Area_Shield/Sprite2D.modulate = Color (1, 0, 0, 1)
		$Area_Shield/Sprite2D.visible = true
	
	
func _on_area_shield_body_exited(body):
	if body.is_in_group("Player") and body.global_position != global_position and body.summoner != summoner:
		body.is_geting_damage_shield["fire"] -= rng.randf_range(0.4, 0.7)
		in_shield_bodies.erase(body)
	if in_shield_bodies.is_empty() == true:
		$Area_Shield/Sprite2D.modulate = Color (0, 0, 0, 1)
		$Area_Shield/Sprite2D.visible = false
	
