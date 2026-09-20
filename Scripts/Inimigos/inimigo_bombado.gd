extends Inimigo


var CHASE_SPEED := 150.0

var current_speed := 0.0

var state := "walk"
var state_timer := 0.0

var attack_cooldown := 0.8
var attack_timer := 0.0

var origin_x := 0.0

@onready var sprite := $Sprite2D
@onready var anim := $AnimationPlayer


func _ready():

	super._ready()

	WALK_SPEED = 55.0
	RUN_SPEED = CHASE_SPEED
	ACCELERATION = 700.0

	vida = 3

	state_timer = randf_range(1.0, 2.0)

	add_to_group("inimigoGrande")

	origin_x = global_position.x


func processar_ia(delta):

	match vida:

		1:
			sprite.modulate = Color(1.0, 0.25, 0.25, 1.0)

		2:
			sprite.modulate = Color(1.0, 0.504, 0.504, 1.0)

		_:
			sprite.modulate = Color.WHITE

	attack_timer = max(attack_timer - delta, 0.0)

	match state:

		"walk":
			walk_state(delta)

		"idle":
			idle_state(delta)

		"attack":
			attack_state(delta)


func walk_state(delta):

	tocar_animacao("walk")

	var target_speed := WALK_SPEED

	if is_instance_valid(player):

		var diff_y = abs(
			player.global_position.y - global_position.y
		)

		if diff_y < 32.0:

			target_speed = CHASE_SPEED

			var dir = sign(
				player.global_position.x - global_position.x
			)

			if dir != 0:

				direction = dir
				atualizar_direcao()

	current_speed = move_toward(
		current_speed,
		target_speed,
		ACCELERATION * delta
	)

	velocity.x = current_speed * direction

	anim.speed_scale = 2.3 if is_instance_valid(player) else 1.0

	if not is_instance_valid(player):

		var dist_patrol = global_position.x - origin_x

		if dist_patrol > 120.0 and direction > 0:
			virar()

		elif dist_patrol < -120.0 and direction < 0:
			virar()

		if has_node("direcao") \
		and has_node("pe1") \
		and has_node("pe2"):

			$direcao.force_raycast_update()
			$pe1.force_raycast_update()
			$pe2.force_raycast_update()

			if (
				$direcao.is_colliding()
				or not $pe1.is_colliding()
				or not $pe2.is_colliding()
			) and turn_timer <= 0:

				virar()

	state_timer -= delta

	if state_timer <= 0 and not is_instance_valid(player):

		state = "idle"
		state_timer = randf_range(0.5, 1.2)


func idle_state(delta):

	tocar_animacao("idle")

	velocity.x = move_toward(
		velocity.x,
		0,
		ACCELERATION * delta
	)

	current_speed = 0

	state_timer -= delta

	if is_instance_valid(player):

		state = "walk"
		return

	if state_timer <= 0:

		state = "walk"
		state_timer = randf_range(1.0, 2.0)


func attack_state(delta):

	velocity.x = move_toward(
		velocity.x,
		0,
		ACCELERATION * delta
	)

	current_speed = 0

	state_timer -= delta

	if state_timer <= 0:
		state = "walk"


func morrer_melee(_dir_ataque := 0.0):

	if dead:
		return

	dead = true
	pausar_fisica = false

	ativar_efeitos_morte()
	desativar_colisoes_morte()

	anim.play("death")

	velocity = Vector2.ZERO

	await get_tree().create_timer(0.25).timeout

	pausar_fisica = true
	velocity = Vector2.ZERO

	registrar_kill(400)

	await get_tree().create_timer(1.75).timeout

	queue_free()


func _on_inimigo_hit_box_body_entered(body):

	if dead:
		return

	if body.name == "bala":

		body.queue_free()

		vida -= 1

		$sfx/hit.play()

		if vida <= 0:

			sprite.modulate = Color.WHITE

			await morrer_melee(direction)

		return

	if body.has_method("freezePlayer") and not body.invencivel:

		body.get_parent().gameover()


func _on_visao_ataque_body_entered(body):

	if dead:
		return

	if body.name != "player":
		return

	player = body

	if attack_timer > 0:
		return

	if state == "attack":
		return

	iniciar_ataque()


func _on_visao_ataque_body_exited(body):

	if body == player:
		player = null


func iniciar_ataque():

	state = "attack"

	state_timer = 0.9

	attack_timer = attack_cooldown

	velocity.x = 0
	current_speed = 0

	anim.play("ataque")

	call_deferred("_spawn_ataque")


func _spawn_ataque():

	await get_tree().create_timer(0.2).timeout

	if dead:
		return

	$sfx/ataque.play()

	var onda_scene = preload(
		"res://Cenas/ataque_bombadao.tscn"
	)

	var direita = onda_scene.instantiate()
	direita.global_position = $spawner2.global_position
	direita.direction = 1
	get_parent().add_child(direita)

	var esquerda = onda_scene.instantiate()
	esquerda.global_position = $spawner1.global_position
	esquerda.direction = -1
	get_parent().add_child(esquerda)

	var cam = get_tree().get_current_scene().get_node_or_null(
		"player/Camera2D"
	)

	if cam:
		cam.shake(0.25, 1.5)
