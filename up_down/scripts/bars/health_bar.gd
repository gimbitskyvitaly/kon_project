extends TextureProgressBar

@export var player: BasicPlayer

func _ready():
	player.health_changed.connect(update)
	update()

func update():
	value = player.hp

