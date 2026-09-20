extends Node2D

@onready var texto = $creditos
@onready var fade = $fade

var paginas = [
	"CREDITOS_CEO",
	"CREDITOS_GESTORES",
	"CREDITOS_PROGRAMACAO",
	"CREDITOS_ARTE",
	"CREDITOS_GAME_DESIGN",
	"CREDITOS_MARKETING",
	"CREDITOS_BETA",
	"CREDITOS_BETA_2",
	"CREDITOS_AGRADECIMENTOS"
]

var pagina_atual := 0

const FADE_IN := 1.0
const TEMPO_POR_PAGINA := 4.0
const FADE_OUT := 0.6
const FADE_SKIP := 0.4

var pode_interagir := false
var saindo := false


func _ready() -> void:
	$shader.show()

	Global.salvar_tempo_atual(Global.timerTempo)

	# Começa completamente preto
	fade.modulate.a = 1.0

	# Texto começa pequeno, invisível e um pouco abaixo
	texto.modulate.a = 0.0
	texto.scale = Vector2(0.88, 0.88)
	texto.position.y += 20

	mostrar_pagina()

	# Fade-in inicial
	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(fade, "modulate:a", 0.0, FADE_IN)
	tween.tween_property(texto, "modulate:a", 1.0, 0.8)
	tween.tween_property(texto, "scale", Vector2.ONE, 1.0)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(texto, "position:y", texto.position.y - 20, 0.9)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	await tween.finished

	pode_interagir = true

	iniciar_creditos()


func mostrar_pagina() -> void:
	texto.text = Tradutor.get_text(paginas[pagina_atual])

	# Cada página começa pequena, invisível e levemente abaixo
	texto.modulate.a = 0.0
	texto.scale = Vector2(0.88, 0.88)
	texto.position.y += 15

	var tween = create_tween()
	tween.set_parallel(true)

	# Fade + zoom + movimento
	tween.tween_property(texto, "modulate:a", 1.0, 0.45)

	tween.tween_property(texto, "scale", Vector2.ONE, 0.7)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(texto, "position:y", texto.position.y - 15, 0.7)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)


func iniciar_creditos() -> void:
	for i in range(paginas.size()):

		await get_tree().create_timer(TEMPO_POR_PAGINA).timeout

		if saindo:
			return

		# Saída da página:
		# desaparece enquanto cresce levemente e sobe
		var tween_saida = create_tween()
		tween_saida.set_parallel(true)

		tween_saida.tween_property(texto, "modulate:a", 0.0, 0.3)

		tween_saida.tween_property(texto, "scale", Vector2(1.06, 1.06), 0.35)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN)

		tween_saida.tween_property(texto, "position:y", texto.position.y - 10, 0.35)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN)

		await tween_saida.finished

		if saindo:
			return

		pagina_atual += 1

		if pagina_atual < paginas.size():
			mostrar_pagina()
		else:
			voltar_menu()


func _input(event) -> void:
	if not pode_interagir or saindo:
		return

	if event.is_pressed():
		saindo = true
		pode_interagir = false

		# Fade-out rápido ao pular
		var tween = create_tween()
		tween.tween_property(fade, "modulate:a", 1.0, FADE_SKIP)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN)

		await tween.finished

		get_tree().change_scene_to_file("res://Cenas/Menus/menu.tscn")


func voltar_menu() -> void:
	if saindo:
		return

	saindo = true
	pode_interagir = false

	# Fade-out final curto
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, FADE_OUT)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)

	await tween.finished

	get_tree().change_scene_to_file("res://Cenas/Menus/menu.tscn")
