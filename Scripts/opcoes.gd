
extends Node2D

func _ready() -> void:
	$opcoes/desempenho/check.grab_focus()
	$opcoes/desempenho/check.button_pressed = Global.potatoMode
	$shader.show()
	$opcoes/musica/Control/volumeSlider.value = Global.volume

func _process(_delta: float) -> void:
	if Global.lingua == "ptbr":
		$lang.text = "Linguagem: PT-BR"
	elif Global.lingua == "eng":
		$lang.text = "Language: ENG"

func _on_volume_slider_value_changed(value: float) -> void:
	Global.volume = clampi(int(value), 0, 100)

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
