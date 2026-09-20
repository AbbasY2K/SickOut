extends Button

@export var key := ""
@onready var hoverBotao = get_tree().current_scene.find_child("hoverBotao", true, false)

func _ready():
	text = Tradutor.get_text(key)
	
	await get_tree().process_frame

	pivot_offset = size / 2

	focus_entered.connect(_on_focus)
	focus_exited.connect(_on_unfocus)

func _on_focus():
	if hoverBotao:
		hoverBotao.play()

	create_tween()\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.tween_property(
			self,
			"scale",
			Vector2(1.08, 1.08),
			0.15
		)

func _on_unfocus():
	create_tween()\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.tween_property(
			self,
			"scale",
			Vector2.ONE,
			0.15
		)
