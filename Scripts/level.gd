extends Node2D

@export var faseID: int
@export var nomeFase: String

@export var metaPontuacao := 2500
@export var metaKills := 8
@export var metaTempo := 45.0

var pausavel := true
var pontuacao := 0
var animacao_id := 0
var gameOver := false

var ultima_municao := -1
var texto_municao := ""

var municao_tween: Tween
var municao_pos_original: Vector2

var music_bus_idx := -1
var music_filter: AudioEffectLowPassFilter

var ui_animacoes_originais: Dictionary = {}
var ui_overdose_ativa := false

@onready var digitos: Array[RichTextLabel] = [
	$ui/pontuacao/numeros/digito1,
	$ui/pontuacao/numeros/digito2,
	$ui/pontuacao/numeros/digito3,
	$ui/pontuacao/numeros/digito4,
	$ui/pontuacao/numeros/digito5,
	$ui/pontuacao/numeros/digito6,
	$ui/pontuacao/numeros/digito7,
	$ui/pontuacao/numeros/digito8,
	$ui/pontuacao/numeros/digito9,
	$ui/pontuacao/numeros/digito10
]

@onready var player: Node2D = $player
@onready var label_municao: Label = $ui/municao/label
@onready var barra_stamina: Range = $ui/stamina
@onready var music: AudioStreamPlayer = $sfx/music
@onready var timer_ui: CanvasItem = $ui/timer
@onready var municao: Control = $ui/municao

@onready var parallax_bg = find_child("parallaxBg", true, false)
@onready var tile_set: CanvasItem = find_child("tileSet3", true, false) as CanvasItem

var potato_mode_aplicado := false
var tempo_verificacao_fps := 0.0
var amostras_fps := 0

const TEMPO_VERIFICACAO_FPS := 3.0
const FPS_MINIMO := 30.0

const INTERVALO_CHECAGEM_TIME_SCALE := 0.25
const TEMPO_MAXIMO_TIME_SCALE := 2.0

var tempo_time_scale_alterado := 0.0

func _ready() -> void:
	$ui.show()
	$shader.show()
	$blackout.show()
	$fundo/fundoAnimado.show()
	$ui/bloodshot.hide()

	registrar_animacoes_ui($ui)

	music.stop()
	configurar_audio_music()

	GlobalPerformance.registrar_fase(str(faseID))

	Global.metaPontuacao = metaPontuacao
	Global.metaKills = metaKills
	Global.metaTempo = metaTempo
	Global.nomeFaseAtual = "fase" + str(faseID)

	texto_municao = str(Tradutor.get_text("MUNICAO_LABEL"))

	for digito in digitos:
		digito.text = "0"

	if Global.checkpointPos != Vector2.ZERO:
		player.global_position = Global.checkpointPos
	else:
		player.global_position = $spawnerPlayer.global_position

	$player/ganchoCamera/Camera2D.reset_smoothing()

	RenderingServer.set_default_clear_color(Color.BLACK)

	aplicar_potato_mode()

	var timer_potato := Timer.new()
	timer_potato.wait_time = 0.1
	timer_potato.process_mode = Node.PROCESS_MODE_ALWAYS
	timer_potato.timeout.connect(verificar_potato_mode)
	add_child(timer_potato)
	timer_potato.start()

	get_tree().paused = true
	atualizar_controles_mobile()
	atualizar_municao()

	$blackout/introFase/VBoxContainer/fase.text = str(Tradutor.get_text("FASE" + str(faseID)))
	$blackout/introFase/VBoxContainer/subfase.text = str(Tradutor.get_text("NOME_FASE" + str(faseID)))

	$ui/hoverBotao.volume_db = -90

	await get_tree().process_frame

	$ui/pauseMenu/botao1/voltar.focus_mode = Control.FOCUS_ALL
	$ui/pauseMenu/botao1/voltar.grab_focus()

	if (not OS.is_debug_build() or OS.has_feature("mobile")) and not Global.respawn:
		var animacao_intro := "intro1" if randi() % 2 == 0 else "intro2"
		$blackout/introFase/AnimationPlayer.play(animacao_intro)

		await get_tree().create_timer(5.0).timeout

	get_tree().paused = false
	atualizar_controles_mobile()

	if is_instance_valid($blackout/introFase):
		$blackout/introFase.queue_free()

	Global.respawn = true
	music.play()

	if Global.speedrun:
		timer_ui.show()

	await get_tree().create_timer(0.3).timeout

	if is_instance_valid($ui/hoverBotao):
		$ui/hoverBotao.volume_db = -5

	if is_instance_valid($player):
		$player/sfx/land.volume_db = -6
	
		_monitorar_time_scale()

func _process(delta: float) -> void:
	var overdose_ativa = (
		is_instance_valid(player)
		and player.get("overdoseActive") == true
	)

	if overdose_ativa != ui_overdose_ativa:
		configurar_ui_overdose(overdose_ativa)
	
	if is_instance_valid(player):
		atualizar_municao()
		barra_stamina.value = player.stamina

	if Global.potatoMode:
		tempo_verificacao_fps = 0.0
		amostras_fps = 0
	else:
		tempo_verificacao_fps += delta
		amostras_fps += 1

		if tempo_verificacao_fps >= TEMPO_VERIFICACAO_FPS:
			var fps_medio: float = float(amostras_fps) / tempo_verificacao_fps

			tempo_verificacao_fps = 0.0
			amostras_fps = 0

			if fps_medio < FPS_MINIMO:
				Global.potatoMode = true
				Global.salvar_config()
				aplicar_potato_mode()

func verificar_potato_mode() -> void:
	if potato_mode_aplicado != Global.potatoMode:
		aplicar_potato_mode()

func _monitorar_time_scale() -> void:
	while is_inside_tree():
		await get_tree().create_timer(
			INTERVALO_CHECAGEM_TIME_SCALE,
			true,
			false,
			true
		).timeout

		if not is_inside_tree():
			return

		var overdose_ativa = (
			is_instance_valid(player)
			and player.get("overdoseActive") == true
		)

		if overdose_ativa:
			tempo_time_scale_alterado = 0.0
			continue

		if not is_finite(Engine.time_scale) or absf(Engine.time_scale - 1.0) > 0.001:
			tempo_time_scale_alterado += INTERVALO_CHECAGEM_TIME_SCALE
		else:
			tempo_time_scale_alterado = 0.0

		if tempo_time_scale_alterado >= TEMPO_MAXIMO_TIME_SCALE:
			push_warning("Time Scale travado! Restaurando para 1.0.")
			Engine.time_scale = 1.0
			tempo_time_scale_alterado = 0.0

func aplicar_potato_mode() -> void:
	potato_mode_aplicado = Global.potatoMode
	var mostrar: bool = not Global.potatoMode

	if is_instance_valid(tile_set):
		tile_set.visible = mostrar

	if is_instance_valid(parallax_bg):
		parallax_bg.visible = mostrar

	var chunks = find_child("tileSet3_Chunks", true, false)

	if is_instance_valid(chunks):
		chunks.visible = mostrar

	var escuro = get_node_or_null("escuro")
	if is_instance_valid(escuro):
		escuro.visible = mostrar

	var iluminacao = get_node_or_null("iluminacao")
	if is_instance_valid(iluminacao):
		iluminacao.visible = mostrar
	
	var shader = get_node_or_null("shader")
	if is_instance_valid(shader):
		shader.visible = mostrar

func configurar_audio_music() -> void:
	music_bus_idx = AudioServer.get_bus_index("Music")

	if music_bus_idx == -1:
		AudioServer.add_bus()
		music_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(music_bus_idx, "Music")

	for i in range(AudioServer.get_bus_effect_count(music_bus_idx)):
		var efeito := AudioServer.get_bus_effect(music_bus_idx, i)

		if efeito is AudioEffectLowPassFilter:
			music_filter = efeito
			return

	music_filter = AudioEffectLowPassFilter.new()
	AudioServer.add_bus_effect(music_bus_idx, music_filter, 0)


func atualizar_municao() -> void:
	if not is_instance_valid(player):
		return

	if player.ammo == ultima_municao:
		return

	ultima_municao = player.ammo
	label_municao.text = texto_municao + ": (" + str(player.ammo) + "/" + str(player.MAX_AMMO) + ")"


func atualizar_controles_mobile() -> void:
	if not OS.has_feature("mobile"):
		return

	var gameplay := not get_tree().paused and not gameOver

	$ui/controlesGameplay.visible = gameplay
	$ui/controlesMenu.visible = not gameplay


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause") or event.is_echo():
		return

	if gameOver or not pausavel:
		return

	if get_tree().paused:
		get_tree().paused = false
		atualizar_controles_mobile()

		$ui/pauseMenu.hide()
		$ui/fundo.hide()

		music.volume_db = -5

		if is_instance_valid(music_filter):
			music_filter.cutoff_hz = 5000.0

	else:
		get_tree().paused = true
		atualizar_controles_mobile()

		$ui/pauseMenu.show()
		$ui/fundo.show()

		await get_tree().process_frame

		var focus_owner := get_viewport().gui_get_focus_owner()

		if is_instance_valid(focus_owner):
			focus_owner.release_focus()

		await get_tree().process_frame

		if is_instance_valid($ui/pauseMenu/botao1/voltar):
			$ui/pauseMenu/botao1/voltar.grab_focus()

		music.volume_db = -16

		if is_instance_valid(music_filter):
			music_filter.cutoff_hz = 2000.0


func add_score(valor: int) -> void:
	pontuacao += valor

	animacao_id += 1
	animar_pontuacao(animacao_id)

	$sfx/slot.play()


func registrar_animacoes_ui(node: Node) -> void:
	if node is AnimationPlayer:
		if not ui_animacoes_originais.has(node):
			ui_animacoes_originais[node] = node.speed_scale

	for filho in node.get_children():
		registrar_animacoes_ui(filho)


func configurar_ui_overdose(ativa: bool) -> void:
	ui_overdose_ativa = ativa

	for animacao in ui_animacoes_originais.keys():
		if not is_instance_valid(animacao):
			continue

		if ativa:
			animacao.speed_scale = (
				ui_animacoes_originais[animacao] / Engine.time_scale
			)
		else:
			animacao.speed_scale = ui_animacoes_originais[animacao]

func animar_pontuacao(id: int) -> void:
	var numero_str := "%010d" % pontuacao

	for i in range(10):
		animar_digito(digitos[i], int(numero_str[i]), i, id)


func animar_digito(label: RichTextLabel, destino: int, atraso: int, id: int) -> void:
	await get_tree().create_timer(
		atraso * 0.03,
		true,
		false,
		true
	).timeout

	if id != animacao_id or not is_instance_valid(label):
		return

	for i in range(12):
		if id != animacao_id:
			return

		label.position.y = 10
		label.text = str(randi() % 10)

		var tween := create_tween()
		tween.set_ignore_time_scale(true)
		tween.tween_property(label, "position:y", 0.0, 0.025)

		await tween.finished

		if id != animacao_id or not is_instance_valid(label):
			return

	label.text = str(destino)
	label.scale = Vector2(1.25, 1.25)

	var tween_final := create_tween()
	tween_final.set_ignore_time_scale(true)
	tween_final.tween_property(label, "scale", Vector2.ONE, 0.08)


func salvar_resultado_fase() -> void:
	Global.pontuacaoAtual = pontuacao
	Global.killsAtual = $ui/killCount.kills


func gameover() -> void:
	if gameOver:
		return

	if is_instance_valid(player) and player.get("overdoseActive") == true:
		player.encerrar_overdose()
		configurar_ui_overdose(false)

	gameOver = true

	$sfx/death.play()

	Input.start_joy_vibration(0, 0.75, 0.75, 0.75)
	$ui/fundo.show()
	$ui/vhs.show()

	Global.mortesAtual += 1

	timer_ui.process_mode = Node.PROCESS_MODE_DISABLED

	music.pitch_scale = 0.6
	music.volume_db = -5

	if is_instance_valid(music_filter):
		music_filter.cutoff_hz = 5000.0

		var audio_tween := create_tween()
		audio_tween.tween_property(music_filter, "cutoff_hz", 600.0, 0.5)

	var blood: CanvasItem = $ui/bloodshot
	blood.visible = true
	blood.modulate.a = 0
	blood.position = get_viewport_rect().size / 2
	blood.scale = Vector2(2, 2)
	blood.rotation = randf_range(-0.2, 0.2)

	var blood_tween := create_tween()
	blood_tween.tween_property(blood, "modulate:a", 1.0, 0.05)
	blood_tween.tween_interval(0.25)
	blood_tween.tween_property(blood, "modulate:a", 0.0, 0.25)

	var anchor := Node2D.new()
	add_child(anchor)

	var cam: Camera2D
	var player_node := get_node_or_null("player") as Node2D

	if is_instance_valid(player_node):
		anchor.global_position = player_node.global_position

		cam = player_node.get_node_or_null("ganchoCamera/Camera2D") as Camera2D

		if is_instance_valid(cam):
			cam.reparent(anchor)
			cam.make_current()
			cam.reset_smoothing()

		player_node.queue_free()

	if is_instance_valid(cam):
		var camera_tween := create_tween()
		camera_tween.tween_property(cam, "zoom", Vector2(1.5, 1.75), 1.0)

	await get_tree().create_timer(0.4).timeout

	atualizar_controles_mobile()
	$ui/gameOver.show()

	add_score(-pontuacao)

	await get_tree().process_frame

	var current := get_viewport().gui_get_focus_owner()

	if is_instance_valid(current):
		current.release_focus()

	await get_tree().process_frame

	$ui/gameOver/reiniciar.focus_mode = Control.FOCUS_ALL
	$ui/gameOver/reiniciar.grab_focus()


func _on_menu_pressed() -> void:
	get_tree().paused = false
	atualizar_controles_mobile()
	$ui/gameOver/menu.piscar_botao($ui/gameOver/menu)
	get_viewport().gui_release_focus()

	await get_tree().create_timer(0.5).timeout

	$AnimationPlayer.play("fadeIn")

	await get_tree().create_timer(1.25).timeout

	Global.checkpointPos = Vector2.ZERO
	Global.mortesAtual = 0
	Global.tempoTotal = 0

	get_tree().change_scene_to_file("res://Cenas/Menus/menu.tscn")


func _on_reiniciar_pressed() -> void:
	get_tree().paused = false
	atualizar_controles_mobile()
	$ui/gameOver/reiniciar.piscar_botao($ui/gameOver/reiniciar)
	get_viewport().gui_release_focus()

	await get_tree().create_timer(0.5).timeout

	$AnimationPlayer.play("fadeIn")

	await get_tree().create_timer(0.5).timeout

	get_tree().reload_current_scene()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("inimigo"):
		body.virar()


func _on_checkpoint_1_body_entered(body: Node2D) -> void:
	if body.name == "player":
		pass


func _on_death_zone_0_body_entered(body: Node2D) -> void:
	if body.name == "player":
		gameover()
