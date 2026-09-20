extends Node2D

@export var cor : Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FundoTeste1.modulate = cor
	$FundoTeste2.modulate = cor
	$FundoTeste3.modulate = cor
	$FundoTeste4.modulate = cor
