extends CanvasLayer

@onready var flash = $flash
@onready var sangue = $sangue

var flash_tween: Tween
var sangue_tween: Tween

func _ready() -> void:
	flash.modulate.a = 0.0
	sangue.modulate.a = 0.0


func impacto_kill() -> void:
	if flash_tween:
		flash_tween.kill()

	if sangue_tween:
		sangue_tween.kill()

	# FLASH
	flash.modulate.a = 1.0

	flash_tween = create_tween()
	flash_tween.tween_property(
		flash,
		"modulate:a",
		0.0,
		0.05
	)

	# SANGUE
	sangue.position = get_viewport().get_visible_rect().size / 2

	sangue.rotation = randf_range(-0.4, 0.4)

	var escala_base = 5.4
	var escala = randf_range(
		escala_base * 1.0,
		escala_base * 1.4
	)

	sangue.scale = Vector2.ONE * escala

	# Aparece instantaneamente
	sangue.modulate.a = 1.0

	sangue_tween = create_tween()

	# Fica visível por um instante
	sangue_tween.tween_interval(0.12)

	# Some suavemente
	sangue_tween.tween_property(
		sangue,
		"modulate:a",
		0.0,
		0.20
	)
