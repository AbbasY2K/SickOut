extends Node2D

var floating_nodes := []
var floating_data := []
var float_time := 0.0

func _ready() -> void:
	if Global.lingua == null:
		get_tree().change_scene_to_file("res://Cenas/lang.tscn")
		
		return

	if Global.animacao == true:
		$video.start()

	var joypads = Input.get_connected_joypads()

	if joypads.size() > 0:
		var device = joypads[0]
		Input.set_joy_light(device, Color.WEB_GREEN)

	var leaderboard = Global.pegar_leaderboard()

	leaderboard.sort_custom(func(a, b):
		return a["tempo"] < b["tempo"]
	)

	if leaderboard.size() > 5:
		leaderboard.resize(5)

	var texto = "[center][wave]LEADERBOARD - SPEEDRUN[/wave][/center]\n\n"

	for i in leaderboard.size():

		var player = leaderboard[i]

		var cor = "white"

		if i == 0:
			cor = "#FFD700"
		elif i == 1:
			cor = "#C0C0C0"
		elif i == 2:
			cor = "#CD7F32"

		texto += "[color=%s]%d. %s - %s[/color]\n" % [
			cor,
			i + 1,
			player["nome"],
			player["tempoFormatado"]
		]

	$leaderboard/info.bbcode_enabled = true
	$leaderboard/info.text = texto
	$fitas.text = "fitas: " + str(Global.fitas.size()) + "/10"

	Global.speedrun = false
	$shader.show()
	$blackout.show()
	
	floating_nodes = [
	$speedrun
]

	for node in floating_nodes:
		floating_data.append({
			"base_pos": node.position,
			"offset": randf() * TAU,
			"speed": randf_range(0.45, 0.7),
			"amplitude": randf_range(3.0, 6.0)
		})

func _process(_delta: float) -> void:
	float_time += _delta

	for i in floating_nodes.size():
		var data = floating_data[i]

		floating_nodes[i].position = data.base_pos + Vector2(
			sin(float_time * data.speed + data.offset) * data.amplitude * 0.4,
			cos(float_time * data.speed + data.offset) * data.amplitude
		)

	if Input.is_action_just_pressed("toggleAnim"):

		Global.animacao = !Global.animacao
		$click.play()

		if Global.animacao:
			$video.start()
			$video.start()
		else:
			$video.stop()
			$video.stop()

func _on_play_pressed() -> void:
	get_viewport().gui_release_focus()
	$hoverBotao.volume_db = -90
	$video.stop()
	$music.stop()

	$AnimationPlayer.play("flash")
	await get_tree().create_timer(5.5).timeout
	get_tree().change_scene_to_file("res://Cenas/Fases/tutorial.tscn")

func _on_historia_pressed() -> void:
	$historiaPainel/fechar.grab_focus()
	$historiaPainel.show()
	$video.stop()

func _on_speedrun_pressed() -> void:
	get_viewport().gui_release_focus()
	$hoverBotao.volume_db = -90
	$video.stop()
	
	piscar_botao($speedrun)

	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in2")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Cenas/inputSpeedrun.tscn")

func _on_creditos_pressed() -> void:
	get_viewport().gui_release_focus()
	$hoverBotao.volume_db = -90
	$video.stop()

	piscar_botao($creditos)

	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in2")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Cenas/Cutscenes/creditos.tscn")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "outLogo" or anim_name == "out":
		$play.grab_focus()

func _on_video_timeout() -> void:
	$AnimationPlayer.play("in")
	get_viewport().gui_release_focus()
	
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Cenas/gameplayVideo.tscn")

func _on_fechar_pressed() -> void:
	$historiaPainel.hide()
	$historia.grab_focus()
	$video.start()

func _on_log_pressed() -> void:
	GlobalPerformance.gerar_relatorio()

func _on_opcoes_pressed() -> void:
	get_viewport().gui_release_focus()
	$hoverBotao.volume_db = -90
	$video.stop()
	
	piscar_botao($opcoes)

	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in2")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Cenas/Menus/opcoes.tscn")

func _on_fases_pressed() -> void:
	get_viewport().gui_release_focus()
	$hoverBotao.volume_db = -90
	$video.stop()

	piscar_botao($fases)

	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in2")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Cenas/Menus/fases.tscn")


func _on_info_pressed() -> void:
	get_viewport().gui_release_focus()
	$hoverBotao.volume_db = -90
	$video.stop()
	
	piscar_botao($info)

	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in2")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Cenas/Menus/opcoes.tscn")

func piscar_botao(botao: Control) -> void:
	$selectBotao.play()

	var cor_original = botao.modulate

	var tween = create_tween()
	for i in range(2):
		tween.tween_property(botao, "modulate", Color.WHITE, 0.04)
		tween.tween_property(botao, "modulate", Color(1, 1, 1, 0.2), 0.04)

	tween.tween_property(botao, "modulate", cor_original, 0.04)
