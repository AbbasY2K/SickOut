extends VBoxContainer

func piscar_botao(botao: Control) -> void:
	$"../selectBotao".play()

	var cor_original = botao.modulate

	var tween = create_tween()
	for i in range(2):
		tween.tween_property(botao, "modulate", Color.WHITE, 0.04)
		tween.tween_property(botao, "modulate", Color(1, 1, 1, 0.2), 0.04)

	tween.tween_property(botao, "modulate", cor_original, 0.04)

func _on_voltar_pressed() -> void:
	piscar_botao($botao1/voltar)
	get_viewport().gui_release_focus()
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false
	$"../..".atualizar_controles_mobile()
	$"../fundo".hide()
	hide()
	$"../../sfx/music".volume_db = -5

func _on_menu_pressed() -> void:
	piscar_botao($botao2/menu)
	get_viewport().gui_release_focus()
	await get_tree().create_timer(0.5).timeout
	$"../../AnimationPlayer".play("fadeIn")
	Global.checkpointPos = Vector2.ZERO
	Global.mortesAtual = 0
	Global.tempoTotal = 0
	await get_tree().create_timer(1.25).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Cenas/Menus/menu.tscn")

func _on_reiniciar_pressed() -> void:
	piscar_botao($botao3/reiniciar)
	get_viewport().gui_release_focus()
	await get_tree().create_timer(0.5).timeout
	$"../../AnimationPlayer".play("fadeIn")
	await get_tree().create_timer(1.25).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()
