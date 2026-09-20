extends Node2D

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		$"../../../sfx/pickUp".play()
		body.regenerateAmmo()
		queue_free()
		
		$"../../..".add_score(120)
