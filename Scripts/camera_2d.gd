
extends Camera2D

var shake_end_time := 0
var shake_strength := 0.0
var original_offset := Vector2.ZERO

func _ready():
	original_offset = offset

func _process(_delta):
	if Time.get_ticks_msec() < shake_end_time:
		offset = original_offset + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = original_offset

func shake(duration: float, strength: float):
	shake_end_time = Time.get_ticks_msec() + int(duration * 1000.0)
	shake_strength = strength
