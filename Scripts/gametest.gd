extends Node2D

@export var faseID : int
@export var nomeFase : String

var gameOver = false

func _ready() -> void:
	$ui.show()
	$shader.show()
	$blackout.show()
	$fundo/fundoAnimado.show()
	$ui/bloodshot.hide()
	
	
	RenderingServer.set_default_clear_color(Color.BLACK)

	get_tree().paused = true

	$blackout/introFase/fase.text = "FASE " + str(faseID)
	$blackout/introFase/subfase.text = nomeFase
	
	await get_tree().process_frame

	$ui/pauseMenu/voltar.focus_mode = Control.FOCUS_ALL
	$ui/pauseMenu/voltar.grab_focus()

	if not OS.is_debug_build() and Global.respawn == false:
		await get_tree().create_timer(3.5).timeout
		
		get_tree().paused = false
		$blackout/introFase.queue_free()
		Global.respawn = true
	else:
		get_tree().paused = false
		$blackout/introFase.queue_free()


func _process(_delta: float) -> void:
	if has_node("player"):
		var p = $player
		$ui/municao/label.text = "Munição: (" + str(p.ammo) + "/" + str(p.MAX_AMMO) + ")"

	if get_tree().paused == true:
		$sfx/music.volume_db = -15
	else:
		$sfx/music.volume_db = -5


func _input(event) -> void:
	if event.is_action_pressed("pause") and gameOver == false:
		if get_tree().paused:
			get_tree().paused = false
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
			$ui/pauseMenu.show()
			$ui/fundo.show()

			await get_tree().process_frame

			var focus_owner = get_viewport().gui_get_focus_owner()
			if focus_owner:
				focus_owner.release_focus()

			await get_tree().process_frame

			$ui/pauseMenu/voltar.grab_focus()

			var music = $sfx/music
			music.volume_db = -16

			var bus_idx = AudioServer.get_bus_index("Music")
			var effect = AudioServer.get_bus_effect(bus_idx, 0)
			if effect is AudioEffectLowPassFilter:
				effect.cutoff_hz = 2000.0

func gameover():
	$sfx/death.play()
	Input.start_joy_vibration(0, 0.75, 0.75, 0.75)

	gameOver = true

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
	$ui/gameOver.show()

	await get_tree().process_frame

	var current = get_viewport().gui_get_focus_owner()
	if current:
		current.release_focus()

	await get_tree().process_frame

	$ui/gameOver/botoes/reiniciar.focus_mode = Control.FOCUS_ALL
	$ui/gameOver/botoes/reiniciar.grab_focus()


func _on_death_zone_body_entered(body: Node2D) -> void:
	if body.name == "player":
		gameover()


func _on_menu_pressed() -> void:
	get_tree().paused = false
	$AnimationPlayer.play("fadeIn")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Cenas/Menus/menu.tscn")


func _on_reiniciar_pressed() -> void:
	get_tree().paused = false
	$AnimationPlayer.play("fadeIn")
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("inimigo"):
		body.virar()


func _on_checkpoint_1_body_entered(body: Node2D) -> void:
	if body.name == "player":
		pass
