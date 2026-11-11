
extends Node2D

const ESCALA_AMASSADA_Y := 0.16

const TEMPO_AVISO := 0.5
const TEMPO_SUBIDA := 0.2
const TEMPO_ATIVO := 0.8
const TEMPO_DESCIDA := 0.3
const TEMPO_ESPERA := 1.2

@onready var espinho: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

var escalaOriginal := Vector2.ONE
var escalaAmassada := Vector2.ONE


func _ready() -> void:

	escalaOriginal = espinho.scale

	var tamanho_sprite := espinho.get_rect().size
	var alturaOriginal := tamanho_sprite.y * absf(escalaOriginal.y)

	espinho.position.y += alturaOriginal / 2.0

	espinho.centered = false
	espinho.offset = Vector2(
		-tamanho_sprite.x / 2.0,
		-tamanho_sprite.y
	)

	escalaAmassada = Vector2(
		escalaOriginal.x,
		escalaOriginal.y * ESCALA_AMASSADA_Y
	)

	espinho.scale = escalaAmassada

	area.monitoring = false

	iniciar_ciclo()


func iniciar_ciclo() -> void:

	while is_inside_tree():

		await tremer_espinho()

		var subida := create_tween()
		subida.set_trans(Tween.TRANS_SINE)
		subida.set_ease(Tween.EASE_OUT)

		subida.tween_property(
			espinho,
			"scale",
			escalaOriginal,
			TEMPO_SUBIDA
		)

		await get_tree().create_timer(TEMPO_SUBIDA * 0.5).timeout

		area.set_deferred("monitoring", true)

		await subida.finished

		await get_tree().create_timer(TEMPO_ATIVO).timeout

		area.set_deferred("monitoring", false)

		var descida := create_tween()
		descida.set_trans(Tween.TRANS_SINE)
		descida.set_ease(Tween.EASE_IN)

		descida.tween_property(
			espinho,
			"scale",
			escalaAmassada,
			TEMPO_DESCIDA
		)

		await descida.finished

		await get_tree().create_timer(TEMPO_ESPERA).timeout


func tremer_espinho() -> void:

	await get_tree().create_timer(TEMPO_AVISO).timeout

	var tremor := create_tween()

	for i in range(3):

		tremor.tween_property(
			espinho,
			"scale:y",
			escalaAmassada.y * 1.2,
			0.055
		)

		tremor.tween_property(
			espinho,
			"scale:y",
			escalaAmassada.y,
			0.055
		)

	await tremor.finished


func _on_area_2d_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):
		body.takeDamage(global_position)
