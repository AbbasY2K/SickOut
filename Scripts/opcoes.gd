extends Node2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	configurar_audio_sons(self)

	var callback := Callable(self, "_on_audio_node_added")

	if not get_tree().node_added.is_connected(callback):
		get_tree().node_added.connect(callback)

	$opcoes/desempenho/check.button_pressed = Global.potatoMode

	$opcoes/musica/Control/volumeSlider.value = Global.volume_musica
	$opcoes/sons/Control/volumeSlider.value = Global.volume_sons

	$opcoes/desempenho/check.focus_mode = Control.FOCUS_ALL
	$opcoes/musica/Control/volumeSlider.focus_mode = Control.FOCUS_ALL
	$opcoes/sons/Control/volumeSlider.focus_mode = Control.FOCUS_ALL
	$voltar.focus_mode = Control.FOCUS_ALL
	$lang.focus_mode = Control.FOCUS_ALL
	$apagar.focus_mode = Control.FOCUS_ALL

	$opcoes/desempenho/check.grab_focus()
	$shader.show()


func _process(_delta: float) -> void:
	if Global.lingua == "ptbr":
		$lang.text = "Linguagem: PT-BR"
	elif Global.lingua == "eng":
		$lang.text = "Language: ENG"


func eh_player_audio(node: Node) -> bool:
	return (
		node is AudioStreamPlayer
		or node is AudioStreamPlayer2D
		or node is AudioStreamPlayer3D
	)


func configurar_audio_sons(node: Node) -> void:
	if eh_player_audio(node):
		node.bus = "Sons"

	for filho in node.get_children():
		configurar_audio_sons(filho)


func _on_audio_node_added(node: Node) -> void:
	var atual: Node = node

	while atual != null:
		if atual == self:
			configurar_audio_sons(node)
			return

		atual = atual.get_parent()


func _on_volume_slider_value_changed(value: float) -> void:
	Global.definir_volume_musica(value)


func _on_sons_volume_slider_value_changed(value: float) -> void:
	Global.definir_volume_sons(value)


func _on_voltar_pressed() -> void:
	get_viewport().gui_release_focus()
	Global.salvar_config()

	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout

	get_tree().change_scene_to_file("res://Cenas/Menus/menu.tscn")


func _on_lang_pressed() -> void:
	$sfx/lang.play()

	if Global.lingua == "ptbr":
		Global.lingua = "eng"
	else:
		Global.lingua = "ptbr"

	$titulo.text = Tradutor.get_text($titulo.key)
	$opcoes/desempenho/label.text = Tradutor.get_text($opcoes/desempenho/label.key)
	$opcoes/musica/label.text = Tradutor.get_text($opcoes/musica/label.key)
	$opcoes/sons/label.text = Tradutor.get_text($opcoes/sons/label.key)
	$voltar.text = Tradutor.get_text($voltar.key)
	$apagar.text = Tradutor.get_text($apagar.key)


func _on_check_pressed() -> void:
	Global.potatoMode = $opcoes/desempenho/check.button_pressed
	Global.salvar_config()


func _on_apagar_pressed() -> void:
	get_viewport().gui_release_focus()

	Global.apagar_saves()

	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout

	get_tree().paused = false
	get_tree().change_scene_to_file("res://Cenas/Menus/logo.tscn")
