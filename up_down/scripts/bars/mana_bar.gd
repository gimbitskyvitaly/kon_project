extends TextureProgressBar

@export var player: BasicPlayer

func _ready():
	player.mana_changed.connect(update)
	update()

func update():
	value = player.mana
