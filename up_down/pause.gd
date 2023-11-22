extends Label

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			visible = !visible
			get_tree().paused = true
			
		if event.keycode == KEY_O:
			visible = !visible
			get_tree().paused = false
			

			
