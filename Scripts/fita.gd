extends Node2D

@onready var area := $Area2D
@onready var sprite := $Sprite2D
@onready var fita_lore = $"../../../fitaLore"

@export var documento: DocumentoLore
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

		area.monitoring = false
		area.monitorable = false

		sprite.material.set_shader_parameter("pickup_glitch", true)

		Global.fitas[fita_id] = true
		Global.salvar_config()

		var hud = get_tree().get_first_node_in_group("hud")

		if hud:
			hud.mostrar_fita()

		await get_tree().create_timer(0.3).timeout
		await get_tree().create_timer(0.7).timeout

		if documento != null:
			fita_lore.abrir_documento(documento)
		else:
			push_warning("Esta fita não possui um documento atribuído.")

		queue_free()
