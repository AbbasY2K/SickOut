extends Button

@export var fase_id : int

func _ready():
	if Global.lingua == "ptbr":
		text = "Fase " + str(fase_id)
	if Global.lingua == "eng":
		text = "Level " + str(fase_id)
	if fase_id == 0:
		text = "Tutorial"
	
	await get_tree().process_frame

	pivot_offset = size / 2

	focus_entered.connect(_on_focus)
	focus_exited.connect(_on_unfocus)

func _on_focus():
	$"../hoverBotao".play()
	$"../fundo2/desc".text = Tradutor.get_text("FASE" + str(fase_id) + "_DESC")
	
	
	
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
	$"../fundo2/desc".text = ""
	
	create_tween()\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.tween_property(
			self,
			"scale",
			Vector2.ONE,
			0.15
		)
