extends Node2D

const ESCALA_AMASSADA_Y := 0.16

const TEMPO_AVISO := 0.5
const TEMPO_SUBIDA := 0.2
const TEMPO_ATIVO := 0.8
const TEMPO_DESCIDA := 0.3
const TEMPO_ESPERA := 1.2

const FORCA_TREMEDEIRA := 2.0

@onready var espinho: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

var escalaOriginal := Vector2.ONE
var posicaoOriginal := Vector2.ZERO
var escalaAmassada := Vector2.ONE
var posicaoAmassada := Vector2.ZERO
var alturaOriginal := 0.0


func _ready() -> void:
	escalaOriginal = espinho.scale
	posicaoOriginal = espinho.position

	alturaOriginal = espinho.get_rect().size.y * absf(escalaOriginal.y)

	escalaAmassada = Vector2(
		escalaOriginal.x,
		escalaOriginal.y * ESCALA_AMASSADA_Y
	)

	posicaoAmassada = calcular_posicao_ancorada(escalaAmassada)

	espinho.scale = escalaAmassada
	espinho.position = posicaoAmassada

	area.monitoring = false

	iniciar_ciclo()


func calcular_posicao_ancorada(escala: Vector2) -> Vector2:
	var alturaAtual := espinho.get_rect().size.y * absf(escala.y)
	var deslocamento := (alturaOriginal - alturaAtual) / 2.0

	return Vector2(
		posicaoOriginal.x,
		posicaoOriginal.y + deslocamento
	)


func iniciar_ciclo() -> void:
	while is_inside_tree():
		await tremer_espinho()

		var subida := create_tween()
		subida.set_parallel(true)
		subida.set_trans(Tween.TRANS_BACK)
		subida.set_ease(Tween.EASE_OUT)

		subida.tween_property(
			espinho,
			"scale",
			escalaOriginal,
			TEMPO_SUBIDA
		)

		subida.tween_property(
			espinho,
			"position",
			posicaoOriginal,
			TEMPO_SUBIDA
		)

		await get_tree().create_timer(TEMPO_SUBIDA * 0.5).timeout

		area.set_deferred("monitoring", true)

		await subida.finished

		await get_tree().create_timer(TEMPO_ATIVO).timeout

		area.set_deferred("monitoring", false)

		var descida := create_tween()
		descida.set_parallel(true)
		descida.set_trans(Tween.TRANS_SINE)
		descida.set_ease(Tween.EASE_IN)

		descida.tween_property(
			espinho,
			"scale",
			escalaAmassada,
			TEMPO_DESCIDA
		)

		descida.tween_property(
			espinho,
			"position",
			posicaoAmassada,
			TEMPO_DESCIDA
		)

		await descida.finished

		await get_tree().create_timer(TEMPO_ESPERA).timeout


func tremer_espinho() -> void:
	await get_tree().create_timer(TEMPO_AVISO).timeout

	var tremor := create_tween()
	tremor.set_trans(Tween.TRANS_SINE)

	for i in range(3):
		tremor.tween_property(
			espinho,
			"position:x",
			posicaoAmassada.x - FORCA_TREMEDEIRA,
			0.055
		)

		tremor.tween_property(
			espinho,
			"position:x",
			posicaoAmassada.x + FORCA_TREMEDEIRA,
			0.055
		)

	tremor.tween_property(
		espinho,
		"position:x",
		posicaoAmassada.x,
		0.055
	)

	await tremor.finished


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.takeDamage(global_position)
