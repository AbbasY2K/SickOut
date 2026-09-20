extends Node2D

@export var acido: bool

var efeito_acido := preload("res://Cenas/splash.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		if acido:
			criar_efeito(body.global_position)

		body.get_parent().gameover()


func criar_efeito(pos: Vector2) -> void:
	await get_tree().create_timer(0.2).timeout

	var efeito = efeito_acido.instantiate()
	efeito.global_position = pos
	efeito.emitting = true
	get_tree().current_scene.add_child(efeito)
