extends CharacterBody2D

var speed = 150
var hp

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


func _on_area_body_entered(body):
	var i = 0
	for hit_body in $area.get_overlapping_bodies():
		if hit_body.is_in_group("Hit"):
			hit_body.take_damage(10)
		
	queue_free()
