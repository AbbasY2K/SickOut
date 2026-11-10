extends CanvasLayer

@onready var flash = $flash
@onready var sangue = $sangue
@onready var vhs = get_node_or_null("vhs")
@onready var mensagem: RichTextLabel = $mensagem
@onready var bips: Array[AudioStreamPlayer] = [
	$mensagem/bip1,
	$mensagem/bip2,
	$mensagem/bip3,
	$mensagem/bip4
]
@onready var gritos: Array[AudioStreamPlayer] = [
	$gritos/grito1,
	$gritos/grito2,
	$gritos/grito3,
	$gritos/grito4,
	$gritos/grito5
]

var flash_tween: Tween
var sangue_tween: Tween
var sangue_pop_tween: Tween
var vhs_tween: Tween
var mensagem_tween: Tween

var vhs_material: ShaderMaterial

var bip_volume_base := 0.0
var bip_pitch_base := 1.0


func _ready() -> void:
	add_to_group("hud")
	
	flash.modulate.a = 0.0
	sangue.modulate.a = 0.0

	mensagem.bbcode_enabled = true
	mensagem.modulate.a = 0.0
	mensagem.pivot_offset = mensagem.size / 2.0

	for som in bips:
		som.volume_db = bip_volume_base

	if vhs:
		vhs.visible = true

		if vhs is Control:
			vhs.mouse_filter = Control.MOUSE_FILTER_IGNORE

		vhs_material = vhs.material as ShaderMaterial

		if vhs_material:
			vhs_material.set_shader_parameter("intensity", 0.0)
			vhs_material.set_shader_parameter("distortion", 0.009)
			vhs_material.set_shader_parameter("noise_strength", 0.25)
			vhs_material.set_shader_parameter("scanline_strength", 0.14)
			vhs_material.set_shader_parameter("chromatic_shift", 0.0015)
			vhs_material.set_shader_parameter("tracking_strength", 0.008)
		else:
			push_warning("O nó vhs precisa de um ShaderMaterial.")

func mostrar_fita() -> void:
	if mensagem_tween and mensagem_tween.is_valid():
		mensagem_tween.kill()

	mensagem.visible = true
	mensagem.clear()
	mensagem.parse_bbcode("[shake rate=12 level=5]FITA COLETADA![/shake]")
	mensagem.visible_characters = -1
	mensagem.self_modulate = Color(0.55, 0.45, 1.0, 1.0)
	
	

	if vhs_material:
		if vhs_tween and vhs_tween.is_valid():
			vhs_tween.kill()

		vhs_material.set_shader_parameter("intensity", 0.65)

		vhs_tween = create_tween()
		vhs_tween.tween_interval(2.0)

		vhs_tween.tween_method(
			Callable(self, "definir_intensidade_vhs"),
			0.65,
			0.0,
			0.5
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	mensagem.modulate = Color(1, 1, 1, 0)
	mensagem.scale = Vector2.ONE * 0.65
	mensagem.rotation = randf_range(-0.035, 0.035)

	var bip = bips.pick_random()
	bip.stop()
	bip.volume_db = bip_volume_base
	bip.pitch_scale = randf_range(0.9, 1.1)
	bip.play()

	mensagem_tween = create_tween()
	mensagem_tween.set_parallel(true)

	mensagem_tween.tween_property(
		mensagem,
		"modulate:a",
		1.0,
		0.16
	)

	mensagem_tween.tween_property(
		mensagem,
		"scale",
		Vector2.ONE,
		0.25
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	mensagem_tween.tween_property(
		mensagem,
		"rotation",
		0.0,
		0.20
	)

	mensagem_tween.set_parallel(false)
	mensagem_tween.tween_interval(1.5)

	mensagem_tween.tween_property(
		mensagem,
		"modulate:a",
		0.0,
		0.35
	)

	mensagem_tween.tween_callback(
		func():
			mensagem.visible = false
	)

func tocar_grito() -> void:
	var grito: AudioStreamPlayer = gritos.pick_random()

	grito.stop()
	grito.pitch_scale = randf_range(0.85, 1.20)
	grito.play()

func mostrar_combo(nivel: int) -> void:
	if mensagem_tween and mensagem_tween.is_valid():
		mensagem_tween.kill()

	var texto: String
	var tempo_leitura: float
	var escala_inicial: float

	match nivel:
		1:
			texto = "[shake rate=12 level=5]KILL![/shake]"
			tempo_leitura = 1.0
			escala_inicial = 0.65

		2:
			texto = "[shake rate=18 level=8]KILL STREAK x2![/shake]"
			tempo_leitura = 1.2
			escala_inicial = 0.60

		_:
			texto = "[shake rate=22 level=11]KILL STREAK MAX![/shake]"
			tempo_leitura = 1.5
			escala_inicial = 0.55

	# REINICIA COMPLETAMENTE A MENSAGEM
	mensagem.self_modulate = Color(1.0, 0.08, 0.08, 1.0)
	mensagem.visible = true
	mensagem.clear()
	mensagem.parse_bbcode(texto)
	mensagem.visible_characters = -1

	mensagem.modulate = Color(1.0, 1.0, 1.0, 0.0)
	mensagem.scale = Vector2.ONE * escala_inicial
	mensagem.rotation = randf_range(-0.035, 0.035)

	# SOM DO COMBO
	var volume_extra := 0.0
	var aumento_pitch := 1.0

	match nivel:
		1:
			volume_extra = 0.0
			aumento_pitch = 1.0
		2:
			volume_extra = 2.0
			aumento_pitch = 1.15
		_:
			volume_extra = 4.0
			aumento_pitch = 1.30

	var bip_escolhido: AudioStreamPlayer = bips.pick_random()

	bip_escolhido.stop()
	bip_escolhido.volume_db = bip_volume_base + volume_extra

	var variacao_pitch := randf_range(0.82, 1.22)
	bip_escolhido.pitch_scale = (
		bip_pitch_base
		* aumento_pitch
		* variacao_pitch
	)

	bip_escolhido.play()

	# ENTRADA
	mensagem_tween = create_tween()
	mensagem_tween.set_parallel(true)

	mensagem_tween.tween_property(
		mensagem,
		"modulate:a",
		1.0,
		0.16
	)

	mensagem_tween.tween_property(
		mensagem,
		"scale",
		Vector2.ONE,
		0.25
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	mensagem_tween.tween_property(
		mensagem,
		"rotation",
		0.0,
		0.20
	)

	# TEMPO DE LEITURA
	mensagem_tween.set_parallel(false)
	mensagem_tween.tween_interval(tempo_leitura)

	# SAÍDA
	mensagem_tween.tween_property(
		mensagem,
		"modulate:a",
		0.0,
		0.35
	)

	# OCULTA AO TERMINAR
	mensagem_tween.tween_callback(
		func():
			mensagem.visible = false
	)


func definir_intensidade_vhs(valor: float) -> void:
	if vhs_material:
		vhs_material.set_shader_parameter("intensity", valor)


func segundo_flash() -> void:
	flash.modulate.a = 0.34


func impacto_kill(nivel: int = 1) -> void:
	nivel = clampi(nivel, 1, 3)

	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()

	if sangue_tween and sangue_tween.is_valid():
		sangue_tween.kill()

	if sangue_pop_tween and sangue_pop_tween.is_valid():
		sangue_pop_tween.kill()

	if vhs_tween and vhs_tween.is_valid():
		vhs_tween.kill()

	var flash_cor: Color
	var flash_alpha: float
	var flash_duracao: float

	var intensidade_vhs: float
	var vhs_pausa: float
	var duracao_vhs: float

	var escala_sangue: float
	var rotacao_sangue: float
	var sangue_visivel: float
	var sangue_sumir: float
	var sangue_cor: Color

	match nivel:
		1:
			flash_cor = Color(1.0, 0.94, 0.92)
			flash_alpha = 0.35
			flash_duracao = 0.11

			intensidade_vhs = 0.16
			vhs_pausa = 0.12
			duracao_vhs = 0.35

			escala_sangue = 5.4
			rotacao_sangue = 0.4
			sangue_visivel = 0.25
			sangue_sumir = 0.35
			sangue_cor = Color.WHITE

		2:
			flash_cor = Color(1.0, 0.57, 0.52)
			flash_alpha = 0.48
			flash_duracao = 0.15

			intensidade_vhs = 0.28
			vhs_pausa = 0.24
			duracao_vhs = 0.55

			escala_sangue = 7.8
			rotacao_sangue = 0.65
			sangue_visivel = 0.35
			sangue_sumir = 0.45
			sangue_cor = Color(1.0, 0.80, 0.80, 1.0)

		_:
			flash_cor = Color(1.0, 0.23, 0.29)
			flash_alpha = 0.58
			flash_duracao = 0.12

			intensidade_vhs = 0.42
			vhs_pausa = 0.35
			duracao_vhs = 0.75

			escala_sangue = 10.8
			rotacao_sangue = 0.85
			sangue_visivel = 0.48
			sangue_sumir = 0.60
			sangue_cor = Color(1.0, 0.52, 0.58, 1.0)

	mostrar_combo(nivel)
	get_tree().create_timer(0.25).timeout.connect(tocar_grito)

	# VHS
	if vhs_material:
		vhs_material.set_shader_parameter(
			"intensity",
			intensidade_vhs
		)

		vhs_tween = create_tween()
		vhs_tween.tween_interval(vhs_pausa)

		vhs_tween.tween_method(
			Callable(self, "definir_intensidade_vhs"),
			intensidade_vhs,
			0.0,
			duracao_vhs
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# FLASH
	flash.modulate = Color(
		flash_cor.r,
		flash_cor.g,
		flash_cor.b,
		flash_alpha
	)

	flash_tween = create_tween()

	if nivel == 3:
		flash_tween.tween_property(
			flash,
			"modulate:a",
			0.0,
			flash_duracao
		)

		flash_tween.tween_callback(
			Callable(self, "segundo_flash")
		)

		flash_tween.tween_property(
			flash,
			"modulate:a",
			0.0,
			0.18
		)
	else:
		flash_tween.tween_property(
			flash,
			"modulate:a",
			0.0,
			flash_duracao
		)

	# SANGUE
	var tamanho_final := randf_range(
		escala_sangue,
		escala_sangue * 1.3
	)

	sangue.position = get_viewport().get_visible_rect().size / 2.0
	sangue.rotation = randf_range(
		-rotacao_sangue,
		rotacao_sangue
	)

	sangue.scale = Vector2.ONE * tamanho_final * 0.65
	sangue.modulate = sangue_cor

	sangue_pop_tween = create_tween()
	sangue_pop_tween.tween_property(
		sangue,
		"scale",
		Vector2.ONE * tamanho_final,
		0.13
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	sangue_tween = create_tween()
	sangue_tween.tween_interval(sangue_visivel)

	sangue_tween.tween_property(
		sangue,
		"modulate:a",
		0.0,
		sangue_sumir
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
