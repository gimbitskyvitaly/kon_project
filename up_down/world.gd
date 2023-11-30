extends Node2D

var spawn_tween
var enemy_scene = load("res://enemy.tscn")
var rng = RandomNumberGenerator.new()
var num = rng.randi_range(0, 4)

var spawn_positions = [
	Vector2(350, 275),
	Vector2(620, 175),
	Vector2(730, 275),
	Vector2(620, 390),	
]

func instatiate_enemy():
	var s = enemy_scene.instantiate()
	s.global_position = spawn_positions[rng.randi_range(0, 3)]
	add_child(s)
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	spawn_tween = create_tween().set_loops(100)
	spawn_tween.tween_callback(instatiate_enemy).set_delay(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
