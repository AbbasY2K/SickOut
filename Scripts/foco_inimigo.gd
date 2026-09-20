extends Area2D

var player: Node2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player = body
		player.cameraTarget = $"../obstaculos/inimigos/inimigoGrande0"
		player.cameraTargetOffset = Vector2(-100, 0)

func _on_inimigo_grande_0_tree_exiting() -> void:
	if player:
		player.cameraTarget = null
		player.cameraTargetOffset = Vector2.ZERO
