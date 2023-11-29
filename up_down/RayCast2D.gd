extends RayCast2D

var is_casting = false
var prev_collision
signal beam_ended

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	$Line2D.points[1] = Vector2.ZERO
	beam_ended.connect(func(): prev_collision.modulate = Color.WHITE)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			set_is_casting(event.pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_casting and prev_collision != null:
		if prev_collision.modulate == Color.HOT_PINK:
			beam_ended.emit()
		prev_collision.is_beamed = false
		return
#	var cast_point = target_position
	var cast_point = get_local_mouse_position()
	target_position = cast_point
	force_raycast_update()
	
	
	if is_colliding():
		var collision = get_collider()
		if collision.has_method('take_damage'):
			prev_collision = collision		
			collision.is_beamed = true
			collision.modulate = Color.HOT_PINK
			collision.take_damage(1)
	elif prev_collision != null:
		beam_ended.emit()
		prev_collision.is_beamed = false
#		cast_point = to_local(get_collision_point())
#		collision_particles.process_material.direction = Vector3(
#			get_collision_normal().x, get_collision_normal().y, 0
#		)
#		$CastParticle.global_position = get_collision_normal().angle()
		
	$CastParticle.direction = cast_point
	$CastParticle.position = cast_point
	$Line2D.points[1] = cast_point
	$BeamParticles2D.rotation = position.direction_to(cast_point).angle()
#	print($Line2D.get_angle_to(position + Vector2(0, 1)))
	$BeamParticles2D.position = cast_point / 2
#	$BeamParticles2D.direction = cast_point
	$BeamParticles2D.emission_rect_extents.x = cast_point.length() / 2
	
	
func set_is_casting(cast):
	is_casting = cast
	
	$CastParticle.emitting = is_casting
	$CastParticle2.emitting = is_casting	
	$BeamParticles2D.emitting = is_casting
	
	if is_casting:
		appear()
	else:
		disappear()
	set_physics_process(is_casting)
	
func appear():
	create_tween().tween_property($Line2D, "width", 2.2, 0.1)
	
func disappear():
	create_tween().tween_property($Line2D, "width", 0.0, 0.1)
