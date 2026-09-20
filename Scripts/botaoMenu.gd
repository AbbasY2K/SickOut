extends Button

@export var key := ""
@onready var hoverBotao = get_tree().current_scene.find_child("hoverBotao", true, false)
@onready var selectBotao = get_tree().current_scene.find_child("selectBotao", true, false)
var tween_pulso: Tween

func piscar_botao(botao: Control) -> void:
	selectBotao.play()

	var cor_original = botao.modulate

	var tween = create_tween()
	for i in range(2):
		tween.tween_property(botao, "modulate", Color.WHITE, 0.04)
		tween.tween_property(botao, "modulate", Color(1, 1, 1, 0.2), 0.04)

	tween.tween_property(botao, "modulate", cor_original, 0.04)

func _ready():
	text = Tradutor.get_text(key)
	
	await get_tree().process_frame

	pivot_offset = size / 2

	focus_entered.connect(_on_focus)
	focus_exited.connect(_on_unfocus)

func _on_focus():
	if hoverBotao:
		hoverBotao.play()

	if tween_pulso:
		tween_pulso.kill()

	scale = Vector2.ONE

	tween_pulso = create_tween()
	tween_pulso.set_loops()

	tween_pulso.tween_property(self, "scale", Vector2(1.08, 1.08), 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	tween_pulso.tween_property(self, "scale", Vector2(1.04, 1.04), 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

func _on_unfocus():
	if tween_pulso:
		tween_pulso.kill()

	create_tween()\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.tween_property(self, "scale", Vector2.ONE, 0.2)
