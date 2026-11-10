extends Node2D

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.ativar_overdose()

		$"../../../sfx/overdose".play()
		$"../../..".add_score(220)
		queue_free()
