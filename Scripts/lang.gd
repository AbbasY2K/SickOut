extends Node2D

func _ready() -> void:
	$ptbr.grab_focus()

func _on_ptbr_pressed() -> void:
	$ptbr.release_focus()
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	Global.lingua = "ptbr"
	Global.salvar_config()
	get_tree().change_scene_to_file("res://Cenas/Menus/menu.tscn")


func _on_eng_pressed() -> void:
	$eng.release_focus()
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	Global.lingua = "eng"
	Global.salvar_config()
	get_tree().change_scene_to_file("res://Cenas/Menus/menu.tscn")
