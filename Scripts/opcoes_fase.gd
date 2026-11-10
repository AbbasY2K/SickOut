extends Node2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	$opcoes/musica/Control/volumeSlider.value = Global.volume
	$opcoes/desempenho/check.button_pressed = Global.potatoMode

	$opcoes/musica/Control/volumeSlider.focus_mode = Control.FOCUS_ALL
	$voltar.focus_mode = Control.FOCUS_ALL
	$lang.focus_mode = Control.FOCUS_ALL

func _process(_delta: float) -> void:
	if Global.lingua == "ptbr":
		$lang.text = "Linguagem: PT-BR"
	elif Global.lingua == "eng":
		$lang.text = "Language: ENG"

func _on_volume_slider_value_changed(value: float) -> void:
	Global.volume = clampi(int(value), 0, 100)

func _on_voltar_pressed() -> void:
	Global.salvar_config()
	get_viewport().gui_release_focus()
	hide()
	$"../pauseMenu/botao3/config".grab_focus()

func _on_lang_pressed() -> void:
	$sfx/lang.play()

	if Global.lingua == "ptbr":
		Global.lingua = "eng"
	else:
		Global.lingua = "ptbr"

	$opcoes/desempenho/label.text = Tradutor.get_text($opcoes/desempenho/label.key)
	$titulo.text = Tradutor.get_text($titulo.key)
	$opcoes/musica/label.text = Tradutor.get_text($opcoes/musica/label.key)
	$opcoes/sons/label.text = Tradutor.get_text($opcoes/sons/label.key)
	$voltar.text = Tradutor.get_text($voltar.key)
	$apagar.text = Tradutor.get_text($apagar.key)

func _on_check_pressed() -> void:
	Global.potatoMode = $opcoes/desempenho/check.button_pressed
	Global.salvar_config()
