extends Node2D

func _input(event):
	if event.is_pressed():
		$ColorRect/AnimationPlayer.play("in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Cenas/Menus/menu.tscn")

func _on_video_stream_player_finished() -> void:
	$ColorRect/AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Cenas/Menus/menu.tscn")
