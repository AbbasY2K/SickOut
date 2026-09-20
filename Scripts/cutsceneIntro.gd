extends Node2D

func _ready() -> void:
	$shader.show()

func legenda(texto: String):
	$legenda.text = texto
