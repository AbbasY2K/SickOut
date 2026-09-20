extends Button

@export var key := ""

func _ready():
	text = Tradutor.get_text(key)
