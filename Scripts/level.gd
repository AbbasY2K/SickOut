extends Node2D

@export var faseID : int
@export var nomeFase : String

@export var metaPontuacao := 2500
@export var metaKills := 8
@export var metaTempo := 45.0

var pausavel = true

var pontuacao := 0

@onready var digitos = [
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

var animacao_id := 0

var municao_tween: Tween
@onready var municao = $ui/municao
var municao_pos_original: Vector2

var gameOver = false

func _ready() -> void:
	$ui.show()
	$shader.show()
	$blackout.show()
	$fundo/fundoAnimado.show()
	$ui/bloodshot.hide()
	$sfx/music.stop()


	GlobalPerformance.registrar_fase(str(faseID))

	Global.metaPontuacao = metaPontuacao
	Global.metaKills = metaKills
	Global.metaTempo = metaTempo
	Global.nomeFaseAtual = "fase" + str(faseID)

	for d in digitos:
		d.text = "0"

	if Global.checkpointPos != Vector2.ZERO:
		$player.global_position = Global.checkpointPos
	else:
		$player.global_position = $spawnerPlayer.global_position

	$player/ganchoCamera/Camera2D.reset_smoothing()

	RenderingServer.set_default_clear_color(Color.BLACK)

	get_tree().paused = true
	atualizar_controles_mobile()

	$blackout/introFase/VBoxContainer/fase.text = str(Tradutor.get_text("FASE" + str(faseID)))
	$blackout/introFase/VBoxContainer/subfase.text = str(Tradutor.get_text("NOME_" + "FASE" + str(faseID)))

	# Impede o primeiro som de hover
	$ui/hoverBotao.volume_db = -90

	await get_tree().process_frame

	$ui/pauseMenu/botao1/voltar.focus_mode = Control.FOCUS_ALL
	$ui/pauseMenu/botao1/voltar.grab_focus()

	if (not OS.is_debug_build() or OS.has_feature("mobile")) and Global.respawn == false:
		if randi() % 2 == 0:
			$blackout/introFase/AnimationPlayer.play("intro1")
		else:
			$blackout/introFase/AnimationPlayer.play("intro2")
		await get_tree().create_timer(5).timeout

		get_tree().paused = false
		atualizar_controles_mobile()
		$blackout/introFase.queue_free()
		Global.respawn = true
		$sfx/music.play()

		if Global.speedrun == true:
			$ui/timer.show()

		await get_tree().create_timer(0.3).timeout
		$ui/hoverBotao.volume_db = -5
		$player/sfx/land.volume_db = -6
	else:
		get_tree().paused = false
		atualizar_controles_mobile()
		$blackout/introFase.queue_free()
		$sfx/music.play()

		if Global.speedrun == true:
			$ui/timer.show()

		await get_tree().create_timer(0.3).timeout
		$ui/hoverBotao.volume_db = -5
		$player/sfx/land.volume_db = -6

func _process(_delta: float) -> void:
	if has_node("player"):
		var p = $player
		$ui/municao/label.text = str(Tradutor.get_text("MUNICAO_LABEL")) + ": (" + str(p.ammo) + "/" + str(p.MAX_AMMO) + ")"

	if get_tree().paused == true:
		$sfx/music.volume_db = -15
	else:
		$sfx/music.volume_db = -5
	
	var player = get_tree().get_first_node_in_group("player")

	if player:
		$ui/stamina.value = player.stamina

func atualizar_controles_mobile():
	if not OS.has_feature("mobile"):
		return

	var gameplay = not get_tree().paused and not gameOver

	$ui/controlesGameplay.visible = gameplay
	$ui/controlesMenu.visible = not gameplay

func _input(event) -> void:
	if event.is_action_pressed("pause") and gameOver == false and pausavel == true:
		if get_tree().paused:
			get_tree().paused = false
			atualizar_controles_mobile()
			$ui/pauseMenu.hide()
			$ui/fundo.hide()
			
			var music = $sfx/music
			music.volume_db = -5

			var bus_idx = AudioServer.get_bus_index("Music")
			var effect = AudioServer.get_bus_effect(bus_idx, 0)
			if effect is AudioEffectLowPassFilter:
				effect.cutoff_hz = 5000.0

		else:
			get_tree().paused = true
			atualizar_controles_mobile()
			$ui/pauseMenu.show()
			$ui/fundo.show()

			await get_tree().process_frame

			var focus_owner = get_viewport().gui_get_focus_owner()
			if focus_owner:
				focus_owner.release_focus()

			await get_tree().process_frame

			$ui/pauseMenu/botao1/voltar.grab_focus()

			var music = $sfx/music
			music.volume_db = -16

			var bus_idx = AudioServer.get_bus_index("Music")
			var effect = AudioServer.get_bus_effect(bus_idx, 0)
			if effect is AudioEffectLowPassFilter:
				effect.cutoff_hz = 2000.0

func add_score(valor:int):
	pontuacao += valor

	animacao_id += 1
	animar_pontuacao(animacao_id)

	$sfx/slot.play()

func animar_pontuacao(id:int):

	var numero_str = "%010d" % pontuacao

	for i in range(10):
		animar_digito(digitos[i], int(numero_str[i]), i, id)


func animar_digito(label: RichTextLabel, destino: int, atraso: int, id: int):

	await get_tree().create_timer(atraso * 0.03).timeout

	if id != animacao_id:
		return

	for i in range(12):

		if id != animacao_id:
			return

		label.position.y = 10
		label.text = str(randi() % 10)

		@warning_ignore("confusable_local_declaration")
		var tween = create_tween()
		tween.tween_property(label, "position:y", 0, 0.025)

		await tween.finished

		if id != animacao_id:
			return

	if id != animacao_id:
		return

	label.text = str(destino)

	label.scale = Vector2(1.25, 1.25)

	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, 0.08)

func salvar_resultado_fase():
	Global.pontuacaoAtual = pontuacao

	Global.killsAtual = $ui/killCount.kills

func gameover():
	$sfx/death.play()
	Input.start_joy_vibration(0, 0.75, 0.75, 0.75)
	$ui/fundo.show()

	gameOver = true
	Global.mortesAtual += 1

	$ui/timer.process_mode = Node.PROCESS_MODE_DISABLED

	var music = $sfx/music
	music.pitch_scale = 0.6
	music.volume_db = -5

	var bus_idx = AudioServer.get_bus_index("Music")

	if bus_idx != -1 and AudioServer.get_bus_effect_count(bus_idx) > 0:
		var effect = AudioServer.get_bus_effect(bus_idx, 0)

		if effect is AudioEffectLowPassFilter:
			effect.cutoff_hz = 5000.0
			var audio_tween = create_tween()
			audio_tween.tween_property(effect, "cutoff_hz", 600.0, 0.5)

	
	var blood = $ui/bloodshot
	blood.visible = true
	blood.modulate.a = 0
	blood.position = get_viewport_rect().size / 2
	blood.scale = Vector2(2, 2)
	blood.rotation = randf_range(-0.2, 0.2)

	var blood_tween = create_tween()
	blood_tween.tween_property(blood, "modulate:a", 1.0, 0.05)
	blood_tween.tween_interval(0.25)
	blood_tween.tween_property(blood, "modulate:a", 0.0, 0.25)

	var anchor = Node2D.new()
	add_child(anchor)

	var cam = null
	var player_node = get_node_or_null("player")
	if player_node and is_instance_valid(player_node):
		anchor.global_position = player_node.global_position
		cam = player_node.get_node_or_null("ganchoCamera/Camera2D")
		if cam and is_instance_valid(cam):
			cam.reparent(anchor)
			cam.make_current()
			cam.reset_smoothing()
		player_node.queue_free()

	var tween = create_tween()
	if cam and is_instance_valid(cam):
		tween.tween_property(cam, "zoom", Vector2(1.5, 1.75), 1.0)

	await get_tree().create_timer(0.4).timeout
	atualizar_controles_mobile()
	$ui/gameOver.show()
	add_score(-pontuacao)

	await get_tree().process_frame

	var current = get_viewport().gui_get_focus_owner()
	if current:
		current.release_focus()

	await get_tree().process_frame

	$ui/gameOver/reiniciar.focus_mode = Control.FOCUS_ALL
	$ui/gameOver/reiniciar.grab_focus()


func _on_death_zone_body_entered(body: Node2D) -> void:
	if body.name == "player":
		gameover()


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
