extends StaticBody2D

@export var item_necessario: String

var player_na_area = null

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_na_area:
		if Global.itens.has(item_necessario):
			Global.itens.erase(item_necessario)
			$open.play()
			await get_tree().create_timer(0.2).timeout
			queue_free()
		else:
			$nope.play()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_na_area = body
		$"../../ui/dica".show()

		if Global.itens.has(item_necessario):
			$"../../ui/dica/Label".text = Tradutor.get_text("PRESS_QUADRADO")
			if OS.has_feature("mobile"):
				$"../../ui/controlesGameplay/interagir1".show()
		else:
			$"../../ui/dica/Label".text = Tradutor.get_text("TRANCADO")
			if OS.has_feature("mobile"):
				$"../../ui/controlesGameplay/interagir1".show()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_na_area:
		player_na_area = null
		$"../../ui/dica".hide()
		if OS.has_feature("mobile"):
			$"../../ui/controlesGameplay/interagir1".hide()
