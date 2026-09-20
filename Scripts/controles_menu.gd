extends Control

func _ready() -> void:
	if not OS.has_feature("mobile"):
		await get_tree().create_timer(0.01).timeout
		queue_free()
