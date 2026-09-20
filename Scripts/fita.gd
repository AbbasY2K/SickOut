extends Node2D

@onready var area := $Area2D
@onready var sprite := $Sprite2D

@export var fita_id := "fita_01"

var collected := false

func _ready():
	if Global.fitas.get(fita_id, false):
		collected = true

		area.monitoring = false
		area.monitorable = false

		sprite.material = null

		$hmmm.queue_free()
		sprite.modulate = Color(0.502, 0.502, 0.502, 0.702)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if collected:
		return

	if body.name == "player":
		collected = true

		$hmmm.stop()
		$grab.play()

		# Impede coletar novamente
		area.monitoring = false
		area.monitorable = false

		# Ativa o glitch forte
		sprite.material.set_shader_parameter("pickup_glitch", true)

		
		Global.fitas[fita_id] = true
		Global.salvar_config()
		
		await get_tree().create_timer(0.3).timeout

		# Espera completar 1 segundo
		await get_tree().create_timer(0.7).timeout

		queue_free()
