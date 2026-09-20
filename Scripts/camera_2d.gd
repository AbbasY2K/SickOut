extends Camera2D

var shake_time := 0.0
var shake_strength := 0.0
var original_offset := Vector2.ZERO

func _ready():
	original_offset = offset

func _process(delta):
	if shake_time > 0:
		shake_time -= delta
		offset = original_offset + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = original_offset

func shake(duration: float, strength: float):
	shake_time = duration
	shake_strength = strength
