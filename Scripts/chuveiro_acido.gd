extends Node2D

@export var toxicidade_por_segundo := 20.0

var player = null

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _process(delta):
	if player != null:
		player.aumentarToxicidade(toxicidade_por_segundo * delta)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player.definirAreaToxica(true)

func _on_body_exited(body):
	if body == player:
		player.definirAreaToxica(false)
		player = null
