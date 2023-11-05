extends Node

var start_speed = 0
var speed = 0
var hp = 100
var is_geting_damage_shield = {"air": false, "fire": false, "water": false}
var glob_pos_from_air_shield = null
var body_from_water_shield = null
var fire_shield_damage = null

func _ready():
	add_to_group("Hit")

func take_damage(d):
	hp -= d
	if hp <= 0:
		queue_free()

