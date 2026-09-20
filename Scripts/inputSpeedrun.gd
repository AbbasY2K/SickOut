extends Node2D

func _ready() -> void:
	call_deferred("_focus_button")

func _focus_button():
	%ShiftButton.grab_focus()

func _on_play_pressed() -> void:
	get_viewport().gui_release_focus()

	var nome = $input/MarginContainer/VBoxContainer/TextInputContainer/TextEdit.text.strip_edges()

	if nome == "":
		nome = "Player"

	Global.criar_player(nome)

	$music.stop()
	$AnimationPlayer.play("flash")
	Global.speedrun = true
	await get_tree().create_timer(5.5).timeout
	get_tree().change_scene_to_file("res://Cenas/Fases/fase3.tscn")
