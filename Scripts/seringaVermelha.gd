extends Node2D

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.addExtraLife()

		$"../../../sfx/vida".play()
		$"../../..".add_score(150)
		queue_free()
