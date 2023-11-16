extends CharacterBody2D

var speed = 150
var element: String
var hp
var wizard: Node
var hit_body

func _ready():
	add_to_group("Hit")
	add_to_group("Bullet")
	hp = 1
	wizard = get_tree().root.get_node("World/Wizard")
	
func take_damage(d):
	hp -= d
	if hp <= 0:
		queue_free()
		
func _physics_process(delta):
#	print(global_position)	
	position += velocity * speed * delta


func _on_area_body_entered(body):
	print('BULLET ENTERED')
	if element and body.is_in_group("Player") and body.position != position:
		var missile_effect = wizard.spell_effects['missile'][element]
		var missile_params = wizard.default_spell_params['missile'][element]['created']
		missile_params['body'] = body
		missile_params['global_position'] = global_position
		missile_params['slowdown_center'] = self
		wizard.process_element_effect(
			element,
			missile_effect,
			missile_params
		)
		hit_body = body
	
	if element == 'water':
		var tween = create_tween()
		tween.tween_callback(queue_free).set_delay(5)
	else:
		queue_free()


func _on_tree_exited():
	if element and hit_body and hit_body.is_in_group("Player") and hit_body.position != position:
		print('BULLET EXITED')		
		var missile_effect = wizard.spell_effects['missile'][element]
		var missile_params = wizard.default_spell_params['missile'][element]['removed']
		missile_params['body'] = hit_body
		missile_params['global_position'] = null
		missile_params['slowdown_center'] = null
		wizard.process_element_effect(
			element,
			missile_effect,
			missile_params
		)
