extends Node2D

var kills = 0
@onready var texto  = $HBoxContainer/texto2

func _process(_delta: float) -> void:
	texto.text = str(kills)

func add_count():
	kills += 1

	texto.scale = Vector2(1.3, 1.3)

	var pos_original = texto.position

	var tween = create_tween()
	tween.parallel().tween_property(texto, "scale", Vector2.ONE, 0.08)
	tween.parallel().tween_property(texto, "position", pos_original + Vector2(3, 0), 0.02)
	tween.tween_property(texto, "position", pos_original + Vector2(-3, 0), 0.02)
	tween.tween_property(texto, "position", pos_original, 0.02)
