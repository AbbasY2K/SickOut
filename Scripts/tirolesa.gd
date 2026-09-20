extends Node2D

@onready var pontoA = $pontoA
@onready var pontoB = $pontoB
@onready var fio = $fio

var player = null
var gancho = null

var interagivel := false

var offset_lateral := 0
var offset_vertical := 0

var usando_tirolesa := false

var tirolesa_dist := 0.0
var tirolesa_speed := 300.0

var sprite_offset_aplicado := false


func _ready():
	fio.size.y = 1
	_update_fio()
	await get_tree().process_frame
	atualizar_referencias()


func _physics_process(delta):
	_update_fio()
	
	if player == null:
		atualizar_referencias()
		return
	
	if usando_tirolesa:
		_move_along_tirolesa(delta)
	elif interagivel and Input.is_action_just_pressed("interact"):
		_start_tirolesa()


func atualizar_referencias():
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() > 0:
		player = players[0]
		gancho = player.get_node_or_null("gancho")


func _start_tirolesa():
	if player == null:
		return
	
	usando_tirolesa = true
	tirolesa_dist = 0
	
	player.freezePlayer()
	player.anim.play("tirolesa")
	$subirTirolesa.play()

	player.sprite.offset.y = 10
	sprite_offset_aplicado = true


func _update_fio():
	var dir = pontoB.global_position - pontoA.global_position
	var length = dir.length()
	var angle = dir.angle()

	var perp = Vector2(-dir.y, dir.x).normalized() * offset_lateral
	var vertical = Vector2(0, offset_vertical)

	fio.global_position = pontoA.global_position + perp + vertical
	fio.rotation = angle
	fio.size.x = length


func _move_along_tirolesa(delta):
	if player == null:
		return

	$tirolesa.play()

	var total_dist = pontoA.global_position.distance_to(pontoB.global_position)
	tirolesa_dist += tirolesa_speed * delta
	
	var t = tirolesa_dist / total_dist
	t = clamp(t, 0.0, 1.0)

	var nova_pos = pontoA.global_position.lerp(pontoB.global_position, t)

	if gancho:
		gancho.global_position = nova_pos

	player.global_position = nova_pos

	var dir = pontoB.global_position - pontoA.global_position
	player.rotation = dir.angle() * 0.2

	if t >= 1.0:
		_end_tirolesa()

	if Input.is_action_just_pressed("jump"):
		_end_tirolesa()
		player.velocity.y = -400


func _end_tirolesa():
	if player == null:
		return

	usando_tirolesa = false
	player.rotation = 0

	if sprite_offset_aplicado:
		player.sprite.offset.y = 0
		sprite_offset_aplicado = false

	player.unfreezePlayer()
	$tirolesa.stop()


func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		interagivel = true
		player = body
		gancho = player.get_node_or_null("gancho")
		$"../../../ui/dica".show()
		$"../../../ui/dica/Label".text = Tradutor.get_text("PRESS_QUADRADO")
		if OS.has_feature("mobile"):
			$"../../../ui/controlesGameplay/interagir1".show()


func _on_area_2d_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		interagivel = false
		$"../../../ui/dica".hide()
		if OS.has_feature("mobile"):
			$"../../../ui/controlesGameplay/interagir1".hide()
