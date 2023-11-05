extends CharacterBody2D

var speed = 150
var start_speed = 150
var hp
var dir_anim = ["left", "left_up", "up", "right_up", "right", "right_down", "down", "left_down"]

var is_geting_damage_shield = {"air": false, "fire": false, "water": false}
var glob_pos_from_air_shield = null
var body_from_water_shield = null
var fire_shield_damage = null
var ind = -1

func _ready ():
	add_to_group("Hit")
	add_to_group ("Bullet")
	hp = 1
	
func take_damage(d):
	#print (d)
	hp -= d
	if hp <= 0:
		queue_free()
		
func _physics_process(delta):
	#print (position)
	position += velocity * speed * delta
	$AnimationPlayer.play("spell_attack_" + "right")


func _on_area_body_entered(body):
	var i = 0
	for hit_body in $area.get_overlapping_bodies():
		if hit_body.is_in_group("Hit"):
			hit_body.take_damage(10)
		
	queue_free()
