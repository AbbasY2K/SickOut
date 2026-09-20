extends Node2D

func _ready() -> void:
	$volumeSlider.grab_focus()
	$shader.show()

	$volumeSlider.value = Global.volume


func _process(_delta):
	var focused = get_viewport().gui_get_focus_owner()

	if Global.lingua == "ptbr":
		$lang.text = "Linguagem: PT-BR"
	if Global.lingua == "eng":
		$lang.text = "Language: ENG"

func _on_volume_slider_value_changed(value: float) -> void:
	Global.volume = clamp(int(value), 0, 100)

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
	$volume.text = Tradutor.get_text($volume.key)
	$sons.text = Tradutor.get_text($sons.key)
	$voltar.text = Tradutor.get_text($voltar.key)
