extends Inimigo


const JUMP_FORCE := -310.0

var fez_pulo_ataque := false

var taking_damage := false

const KNOCKBACK_FORCE := 480.0
const KNOCKBACK_DECAY_LOCAL := 1200.0

var state := "walk"
var state_timer := 0.0

const PREPARE_TIME := 0.12
var prepare_timer := 0.0


func _ready():

	super._ready()

	WALK_SPEED = 35.0
	RUN_SPEED = 105.0

	vida = 2

	state_timer = randf_range(1.5, 3.0)


func processar_ia(delta):

	if taking_damage:

		velocity.x = knockback.x

		knockback.x = move_toward(
			knockback.x,
			0,
			KNOCKBACK_DECAY_LOCAL * delta
		)

		return

	detectar_player()

	if player \
	and state != "prepare" \
	and state != "jump":

		state = "run"

	elif player == null and state == "run":

		state = "idle"
		state_timer = 1.0

	match state:

		"jump":
			jump_state(delta)

		"run":
			run_state()

		"walk":
			walk_state(delta)

		"idle":
			idle_state(delta)

		"prepare":
			prepare_state(delta)


func jump_state(delta):

	velocity.x = move_toward(
		velocity.x,
		direction * 180,
		400 * delta
	)

	velocity += get_gravity() * delta

	if is_on_floor():

		velocity.x *= 0.75
		state = "run"


func pode_pular() -> bool:

	if vida < 2:
		return false

	if fez_pulo_ataque:
		return false

	if not is_on_floor():
		return false

	if not has_node("visaoPulo"):
		return false

	for body in $visaoPulo.get_overlapping_bodies():

		if body == player:
			return true

	return false


func walk_state(delta):

	tocar_animacao("walk")

	velocity.x = WALK_SPEED * direction

	state_timer -= delta

	if not is_on_floor():
		return

	if not has_node("direcao") \
	or not has_node("pe1") \
	or not has_node("pe2"):
		return

	$direcao.force_raycast_update()
	$pe1.force_raycast_update()
	$pe2.force_raycast_update()

	var pe = $pe1 if direction < 0 else $pe2

	if $direcao.is_colliding() and turn_timer <= 0:

		edge_timer = 0.0
		virar()

		return

	if not pe.is_colliding():

		edge_timer += delta

		if edge_timer >= EDGE_TIME and turn_timer <= 0:

			virar()
			edge_timer = 0.0

			return

	else:

		edge_timer = 0.0

	if state_timer <= 0:

		state = "idle"
		state_timer = randf_range(1.0, 2.0)


func idle_state(delta):

	tocar_animacao("idle")

	velocity.x = 0

	state_timer -= delta

	if state_timer <= 0:

		state = "walk"
		state_timer = randf_range(2.0, 4.0)


func run_state():

	tocar_animacao("run")

	if player == null:

		state = "idle"
		state_timer = 1.0

		return

	var dir = sign(
		player.global_position.x - global_position.x
	)

	if dir != 0:

		direction = dir
		atualizar_direcao()

	if pode_pular():

		state = "prepare"
		prepare_timer = PREPARE_TIME
		fez_pulo_ataque = true

		return

	if not is_on_floor():
		return

	if not has_node("direcao") \
	or not has_node("pe1") \
	or not has_node("pe2"):
		return

	$direcao.force_raycast_update()
	$pe1.force_raycast_update()
	$pe2.force_raycast_update()

	var pe = $pe1 if direction < 0 else $pe2

	if $direcao.is_colliding():

		var colisor = $direcao.get_collider()

		if colisor != player:

			velocity.x = 0
			return

	if not pe.is_colliding():

		velocity.x = 0
		return

	velocity.x = RUN_SPEED * direction


func prepare_state(delta):

	velocity.x = move_toward(
		velocity.x,
		0,
		1200 * delta
	)

	prepare_timer -= delta

	if prepare_timer <= 0:

		velocity.x = direction * 280
		velocity.y = -170

		state = "jump"


func morrer_melee(dir_ataque: float):

	if dead:
		return

	vida -= 1

	if vida > 0:

		$sfx/parry.play()

		taking_damage = true

		tocar_animacao("idle")

		var lado = sign(dir_ataque)

		if lado == 0:
			lado = 1

		knockback.x = lado * KNOCKBACK_FORCE

		$Sprite2D.flip_h = lado < 0

		velocity.y = -80

		modulate = Color(1.5, 1.5, 1.5, 1.0)

		await get_tree().create_timer(0.18).timeout

		modulate = Color.WHITE

		await get_tree().create_timer(0.22).timeout

		taking_damage = false

		return

	dead = true
	pausar_fisica = false

	ativar_efeitos_morte()
	desativar_colisoes_morte()

	var lado = sign(dir_ataque)

	if lado == 0:
		lado = 1

	if lado > 0:

		tocar_animacao("death1")
		velocity.x = 160

	else:

		tocar_animacao("death2")
		velocity.x = -160

	velocity.y = 0

	await get_tree().create_timer(0.25).timeout

	pausar_fisica = true
	velocity = Vector2.ZERO

	registrar_kill(350)

	await get_tree().create_timer(2.0).timeout

	queue_free()


func _on_inimigo_hit_box_body_entered(body: Node2D) -> void:

	if body.has_method("freezePlayer") and not body.invencivel:

		body.get_parent().gameover()
