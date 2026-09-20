extends Node2D

@export var caminho : PackedScene

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.freezePlayer()
		Global.checkpointPos = Vector2.ZERO
		
		$"..".pausavel = false
		
		if $ding.playing == false:
			$ding.play()
		
		$AnimationPlayer.play("close")
		
		$"../ui/timer".process_mode = Node.PROCESS_MODE_DISABLED
		
		await get_tree().create_timer(0.5).timeout
		$"../AnimationPlayer".play("fadeIn")
		
		await get_tree().create_timer(1).timeout
		Global.respawn = false
		$"..".salvar_resultado_fase()
		Global.proxFase = caminho
		get_tree().change_scene_to_file("res://Cenas/ranking.tscn")
