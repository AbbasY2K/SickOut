extends Node2D

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		var item_nome = get_parent().item_nome

		Global.itens[item_nome] = true

		$"../pickUp".play()
		queue_free()
