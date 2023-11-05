extends CharacterBody2D

class_name BasicPlayer

var start_speed = 50
@export var speed = 50
@export var impulse_speed = -3
@export var Bullet : PackedScene
@export var Wall : PackedScene

var target = Vector2.ZERO
var v = Vector2.ZERO
var add_v = Vector2.ZERO
var is_attacking = false
var is_hide = false
var is_speed_up = false
var is_going = true
var speed_up_target = null
var ind = -1
var rng = RandomNumberGenerator.new()
var hp = 0
var dir_anim = ["left", "left_up", "up", "right_up", "right", "right_down", "down", "left_down"]

#############################shield
var shield_branch = 0
var shield_radius = 20
var is_geting_damage_shield = {"air": 0, "fire": 0, "water": 0, "eatrt": 0}
var glob_pos_from_air_shield = null
var body_from_water_shield = null
var fire_shield_damage = null
var treshold = 0.5



func _ready():
	add_to_group("Hit")
	add_to_group("Player")
	hp = rng.randf_range(10.0, 100.0)
	

func _on_animation_player_animation_finished(anim_name):
	if anim_name.begins_with("attack"):################attack
		for dir in dir_anim:
			get_node("Area2D/CollisionShape2D_" + dir).disabled = true
		is_attacking = false
		speed_up_target = null########################
		is_going = true#################################
	if anim_name.begins_with("attack"):################speed_up
		is_speed_up = false###############################cotyl_other_anim
		speed_up_target = null########################
		is_going = true#################################
		target = position
	if anim_name.begins_with("attack"):################impulse
		add_v = Vector2.ZERO
		
func animate_going (ind):
	if is_going == true:
		$AnimationPlayer.play ("go_" + dir_anim[ind])
		
func attack (dist_to_attack):
		var bodyes_dist = get_distance_to_group("Hit")
		var b_dist_sorted = bodyes_dist[1]
		if len(b_dist_sorted) > 0 and b_dist_sorted[0] <= dist_to_attack:
			var body_to_hit = bodyes_dist[0][b_dist_sorted[0]]
			attack_enemy(body_to_hit)
		
func attack_enemy (body_to_hit):
		is_going = false
		is_attacking = true
		var v = global_position.direction_to(body_to_hit.position)
		var ind = round(4*(v.angle()/PI))+ 4
		if ind > 7:
			ind = 0
		get_node("Area2D/CollisionShape2D_" + dir_anim[ind]).disabled = false
		$AnimationPlayer.play ("attack_" + dir_anim[ind])
		
func invise ():
		is_hide = !is_hide
		if is_hide == true:
			$Sprite2D.hide()
		else:
			$Sprite2D.show()
			
func speed_up (pos):
		is_going = false
		is_speed_up = true
		speed_up_target = pos
		var v = global_position.direction_to(pos)
		var ind = round(4*(v.angle()/PI))+ 4
		if ind > 7:
			ind = 0
		$AnimationPlayer.play ("attack_" + dir_anim[ind])
		
func take_damage(d):
	#print (d)
	hp -= d
	if hp <= 0:
		queue_free()
		
func shoot(target, spell_scale= 1):
	var b= Bullet.instantiate()
	var dist_from_cust = 20
	v = global_position.direction_to(target)
	var ind = round(4*(v.angle()/PI))+ 4
	if ind > 7:
		ind = 0
	b.position = position + v * dist_from_cust
	b.velocity = v
	b.rotation = v.angle()
	b.scale = Vector2(spell_scale, spell_scale)
	get_tree().root.get_node("World").add_child(b)##################or up in tree
	
func wall_shield (target, shield_scale = 1):
	var w = Wall.instantiate()
	var dist_from_cust = 20
	v = global_position.direction_to(target)
	w.position = position + v * dist_from_cust
	var v2 = global_position.direction_to(get_global_mouse_position())
	w.rotation = v2.angle()
	w.scale = Vector2(shield_scale, shield_scale)
	get_tree().root.get_node("World").add_child(w)##################or up in tree
	
func shield ():
	if shield_branch == 4:
		wall_shield (get_global_mouse_position())
		return
	$Area_Shield/Shield.disabled = !$Area_Shield/Shield.disabled
	$Area_Shield/Sprite2D.visible = not $Area_Shield/Sprite2D.visible
	
	
func take_impulse(impulse_from):
	#v = global_position.direction_to(impulse_from)
	add_v = impulse_speed
	speed_up (impulse_from)
	
func check_get_shield ():
	get_air_shield()
	get_fire_shield(fire_shield_damage)
	get_water_shield()
	
	
func get_air_shield ():
	if is_geting_damage_shield["air"] < treshold or glob_pos_from_air_shield == null:
		return
	if is_in_group ("Player"):
		take_impulse (glob_pos_from_air_shield)
	if is_in_group ("Bullet"):
		queue_free()
		
func get_fire_shield(d):
	if is_geting_damage_shield["fire"] < treshold or fire_shield_damage == null:
		return
	if is_in_group ("Hit"):
		take_damage(d)
		
func get_water_shield ():
	if is_geting_damage_shield["water"] < treshold or body_from_water_shield == null:
		return
	if is_in_group("Player"):
		var dist = body_from_water_shield.position.distance_to(position) - 30
		speed = (dist/shield_radius) * start_speed
		

func _on_area_2d_body_entered(body):
	if body.is_in_group("Hit"):
		#print ("hit")
		body.take_damage(rng.randf_range(-1.0, 1))
		
		
func _on_area_shield_body_entered(body):
	match shield_branch:
		1:
			print ("1")
			if (body.is_in_group ("Player")) and body.position != position:
				body.is_geting_damage_shield["air"] = randf_range(0.4, 1)
				body.glob_pos_from_air_shield = global_position
				$Area_Shield/Sprite2D.modulate = Color(1, 1, 1, 1)
		2:
			print ("2")
			if body.is_in_group ("Hit") and body.position != position:
				body.is_geting_damage_shield["fire"] = randf_range(0.4, 1)
				body.fire_shield_damage = 1
				$Area_Shield/Sprite2D.modulate = Color(1, 0, 0, 1)
		3:
			print ("3")
			if body.is_in_group("Player") and body.position != position:
				body.is_geting_damage_shield["water"] = randf_range(0.4, 1)
				body.body_from_water_shield = self
				$Area_Shield/Sprite2D.modulate = Color(0, 0, 1, 1)
				
			
				
func _on_area_shield_body_exited(body):
	for d in body.is_geting_damage_shield:
		body.is_geting_damage_shield[d] = 0
	body.glob_pos_from_air_shield = null
	body.fire_shield_damage = null
	body.speed = body.start_speed 
	$Area_Shield/Sprite2D.modulate = Color(1, 1, 1, 1)			
		
func get_distance_to_group (group):
	var dist = {}
	for bodyes in get_tree().get_nodes_in_group(group):####################################for current tree
		if bodyes.global_position == global_position:
			continue
		var d = global_position.distance_to(bodyes.global_position)
		dist[d] = bodyes
	var dist_list = dist.keys()
	dist_list.sort()
	return [dist, dist_list]
	
