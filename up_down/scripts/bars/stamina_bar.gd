extends TextureProgressBar

@export var player: BasicPlayer

func _ready():
	player.stamina_changed.connect(update)
	update()

func update():
	value = player.stamina
