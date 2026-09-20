extends CharacterBody2D

var speed := 215.0
var direction := 1

var started := false
var hit_player := false

@onready var ray_parede = $rayParede
@onready var ray_chao = $rayChao


func _ready():
	# flip visual
	$AtaqueChao.flip_h = direction < 0
	$AtaqueChaoSombra.flip_h = direction < 0

	# inverte raycasts corretamente
	ray_parede.target_position.x = abs(ray_parede.target_position.x) * direction
	ray_chao.target_position.x = abs(ray_chao.target_position.x) * direction

	ray_parede.position.x = abs(ray_parede.position.x) * direction
	ray_chao.position.x = abs(ray_chao.position.x) * direction

	# espera 1 frame (raycast estabilizar)
	await get_tree().process_frame
	started = true

	# fail safe
	await get_tree().create_timer(1.5).timeout
	queue_free()


func _physics_process(_delta):

	hit_player = false

	velocity.x = speed * direction
	move_and_slide()

	ray_parede.force_raycast_update()
	ray_chao.force_raycast_update()

	if not started:
		return

	# =========================
	# 1. DETECÇÃO DO PLAYER (PRIORIDADE)
	# =========================
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		var body = col.get_collider()

		if body and body.has_method("freezePlayer") and not body.invencivel:
			body.get_parent().gameover()
			hit_player = true

	# se acertou player → morre e ignora resto
	if hit_player:
		queue_free()
		return


	# =========================
	# 2. PAREDE (IGNORA PLAYER)
	# =========================
	if ray_parede.is_colliding():
		var col = ray_parede.get_collider()

		# só destrói se NÃO for player
		if col and not col.has_method("freezePlayer"):
			call_deferred("queue_free")
			return


	# =========================
	# 3. CHÃO
	# =========================
	if not ray_chao.is_colliding():
		call_deferred("queue_free")
		return


func _on_area_body_entered(body: Node2D) -> void:
	if body.has_method("freezePlayer") and not body.invencivel:
		body.get_parent().gameover()
