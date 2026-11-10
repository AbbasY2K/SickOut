extends Node2D

@export var screen_position := Vector2(0, 0)

func _ready():
	top_level = true

func _process(_delta):
	var camera_transform := get_viewport().get_canvas_transform()

	global_transform = camera_transform.affine_inverse() * Transform2D(
		0.0,
		screen_position
	)
