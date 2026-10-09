extends CharacterBody2D


@export var velocidade := 360.0
@export var tempo_vida := 2.0
@export var tempo_hitstop := 0.2


var direcao: Vector2 = Vector2.RIGHT
var maquina: Node2D = null

var pode_colidir := false
var refletida := false
var hitstop_ativo := false


func _ready() -> void:

	if direcao.length_squared() > 0.0:
		direcao = direcao.normalized()
		rotation = direcao.angle()

	await get_tree().physics_frame

	pode_colidir = true

	await get_tree().create_timer(tempo_vida).timeout

	if is_inside_tree():
		queue_free()


func _physics_process(delta: float) -> void:

	if not pode_colidir:
		return

	var movimento: Vector2 = direcao * velocidade * delta

	var colisao: KinematicCollision2D = move_and_collide(movimento)

	if colisao == null:
		return

	var objeto: Object = colisao.get_collider()

	if not objeto is Node:
		queue_free()
		return

	var alvo := objeto as Node

	if alvo.is_in_group("player"):

		if "invencivel" in alvo and alvo.invencivel:
			queue_free()
			return

		_matar_player(alvo)
		queue_free()
		return

	if refletida and maquina != null and alvo == maquina:

		maquina.morrer_tiro(direcao.x)
		queue_free()
		return

	if alvo is StaticBody2D or alvo is TileMapLayer:
		queue_free()
		return


func rebater(atacante: Node2D) -> void:

	if refletida:
		return

	if not is_instance_valid(maquina):
		queue_free()
		return

	refletida = true

	pode_colidir = false

	add_collision_exception_with(atacante)
	remove_collision_exception_with(maquina)

	direcao = global_position.direction_to(
		maquina.global_position
	)

	rotation = direcao.angle()

	await _hitstop()

	pode_colidir = true

func _hitstop() -> void:

	if hitstop_ativo:
		return

	hitstop_ativo = true

	var tempo_anterior: float = Engine.time_scale

	var camera: Camera2D = get_tree().get_first_node_in_group("player").get_node("ganchoCamera/Camera2D")
	$parry.play()
	camera.shake(tempo_hitstop, 0.5)

	Engine.time_scale = 0.0

	await get_tree().create_timer(
		tempo_hitstop,
		true,
		false,
		true
	).timeout

	Engine.time_scale = tempo_anterior

	hitstop_ativo = false


func _matar_player(alvo: Node) -> void:

	if alvo.name != "player":
		return

	var pai: Node = alvo.get_parent()

	if pai != null and pai.has_method("gameover"):
		pai.gameover()
		return

	if alvo.has_method("gameover"):
		alvo.gameover()
		return

	if alvo.has_method("morrer"):
		alvo.morrer()
