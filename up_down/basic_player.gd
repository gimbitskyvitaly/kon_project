extends CharacterBody2D

class_name BasicPlayer

signal health_changed
signal mana_changed
signal stamina_changed


@export var speed = 50
@export var impulse_speed = -3
@export var Bullet : PackedScene

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
var mana = 0
var stamina = 0
var dir_anim = ["left", "left_up", "up", "right_up", "right", "right_down", "down", "left_down"]

var animation_player: AnimationPlayer

func _ready():
	add_to_group("Hit")
	add_to_group("Player")
	hp = rng.randf_range(10.0, 100.0)
	mana = 100
	stamina = 100

func _on_poof_player_animation_finished(anim_name):
	$AnimatedPoof.hide()

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
		
func animate_going(ind):
	if is_going == true:
		$AnimationPlayer.play("go_" + dir_anim[ind])
		
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
		$AnimationPlayer.play("attack_" + dir_anim[ind])
		
func invise():
		is_hide = !is_hide
		if is_hide == true:
			if mana >= 20:
				spend_mana(20)
				$AnimatedPoof.show()
				$PoofPlayer.play('poof')
				create_tween().tween_property($Sprite2D, "modulate:a", 0.05, 0.2)
		else:
			create_tween().tween_property($Sprite2D, "modulate:a", 1.0, 0.2)
			
func speed_up(pos):
	if stamina >= 10:
		spend_stamina(10)
		is_going = false
		is_speed_up = true
		speed_up_target = pos
		var v = global_position.direction_to(pos)
		var ind = round(4*(v.angle()/PI))+ 4
		if ind > 7:
			ind = 0
		$AnimationPlayer.play("attack_" + dir_anim[ind])
		
func take_damage(d):
	health_changed.emit()
	#print (d)
	hp -= d
	if hp <= 0:
		queue_free()
			
func spend_mana(d):
	mana_changed.emit()
	mana -= d
	
func spend_stamina(d):
	stamina_changed.emit()
	stamina -= d
		
func shoot(target):
	if mana >= 10:
		spend_mana(10)
		var b = Bullet.instantiate()
		var dist_from_cust = 20
		v = global_position.direction_to(target)
		b.position = position + v * dist_from_cust
		b.velocity = v
		get_tree().root.add_child(b)
	
func impulse ():
	$Area_Shield/Shield.disabled = !$Area_Shield/Shield.disabled
	$Area_Shield/Sprite2D.visible = not $Area_Shield/Sprite2D.visible
	
func take_impulse(impulse_from):
	#v = global_position.direction_to(impulse_from)
	add_v = impulse_speed
	speed_up (impulse_from)


func _on_area_2d_body_entered(body):
	if body.is_in_group("Hit"):
		print ("hit")
		body.take_damage(rng.randf_range(-1.0, 1))
		
func _on_area_shield_body_entered(body):
	print (body)
	if body.is_in_group ("Player") and body.position != position:
		body.take_impulse (global_position)
	if body.is_in_group ("Bullet"):
		print (body)
		body.queue_free()
		
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
	
