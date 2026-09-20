extends CharacterBody2D

var WALK_SPEED := 35.0
var RUN_SPEED := 105.0

const JUMP_FORCE := -310.0

var fez_pulo_ataque := false

var vida := 2

var taking_damage := false

var direction := -1

var turn_cooldown := 0.2
var turn_timer := 0.0

var dead := false

var state := "walk"
var state_timer := 0.0

const PREPARE_TIME := 0.12
var prepare_timer := 0.0

var vendo_player := false
var player = null

var knockback := Vector2.ZERO
const KNOCKBACK_FORCE := 480.0
const KNOCKBACK_DECAY := 1200.0

var edge_timer := 0.0
const EDGE_TIME := 0.06

func _ready():
	state_timer = randf_range(1.5, 3.0)
	direction = -1
	$Sprite2D.flip_h = direction > 0

	$ray_visao.add_exception(self)
	add_to_group("inimigo")

func _physics_process(delta):
	if dead:
		move_and_slide()
		return

	if taking_damage:

		if not is_on_floor():
			velocity += get_gravity() * delta

		velocity.x = knockback.x
		knockback.x = move_toward(knockback.x, 0, KNOCKBACK_DECAY * delta)

		move_and_slide()
		return

	turn_timer -= delta

	if not is_on_floor():
		velocity += get_gravity() * delta

	detectar_player()

	if player and state != "prepare" and state != "jump":
		state = "run"
	elif !player and state == "run":
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

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		
		if col:
			var normal = col.get_normal()
			
			if abs(normal.x) > 0.9 and turn_timer <= 0:
				virar()


func detectar_player():
	player = null

	for body in $visao.get_overlapping_bodies():

		if body.is_in_group("player"):

			var dir = body.global_position - global_position

			$ray_visao.target_position = dir
			$ray_visao.force_raycast_update()

			if !$ray_visao.is_colliding() or $ray_visao.get_collider() == body:
				player = body
				return

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

	if !is_on_floor():
		return false

	for body in $visaoPulo.get_overlapping_bodies():
		if body == player:
			return true

	return false

func walk_state(delta):

	if $AnimationPlayer.current_animation != "walk":
		$AnimationPlayer.play("walk")

	velocity.x = WALK_SPEED * direction

	state_timer -= delta

	if !is_on_floor():
		return

	$direcao.force_raycast_update()
	$pe1.force_raycast_update()
	$pe2.force_raycast_update()

	var pe = $pe1 if direction < 0 else $pe2

	if $direcao.is_colliding() and turn_timer <= 0:
		edge_timer = 0.0
		virar()
		return

	if !pe.is_colliding():
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
	if $AnimationPlayer.current_animation != "idle":
		$AnimationPlayer.play("idle")

	velocity.x = 0

	state_timer -= delta

	if state_timer <= 0:
		state = "walk"
		state_timer = randf_range(2.0, 4.0)


func run_state():

	if $AnimationPlayer.current_animation != "run":
		$AnimationPlayer.play("run")

	if player == null:
		state = "idle"
		state_timer = 1.0
		return

	var dir = sign(player.global_position.x - global_position.x)

	if dir != 0:
		direction = dir
		$Sprite2D.flip_h = direction > 0

	if pode_pular():
		state = "prepare"
		prepare_timer = PREPARE_TIME
		fez_pulo_ataque = true
		return

	if !is_on_floor():
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

	if !pe.is_colliding():
		velocity.x = 0
		return

	velocity.x = RUN_SPEED * direction

func prepare_state(delta):
	velocity.x = move_toward(velocity.x, 0, 1200 * delta)

	prepare_timer -= delta

	if prepare_timer <= 0:
		velocity.x = direction * 280
		velocity.y = -170
		state = "jump"


func virar():
	direction *= -1
	$Sprite2D.flip_h = direction > 0
	turn_timer = turn_cooldown
	edge_timer = 0.0

	$direcao.force_raycast_update()
	$pe1.force_raycast_update()
	$pe2.force_raycast_update()

func morrer_melee(dir_ataque: float):

	if dead:
		return

	vida -= 1

	
# PRIMEIRO HIT
	if vida > 0:

		$sfx/parry.play()
		
		taking_damage = true

		$AnimationPlayer.play("idle")

		@warning_ignore("confusable_local_declaration")
		var lado = sign(dir_ataque)

# empurra para longe do ataque
		knockback.x = lado * KNOCKBACK_FORCE
		

# vira para quem atacou
		$Sprite2D.flip_h = lado < 0

		velocity.y = -80

		modulate = Color(1.5,1.5,1.5)

		await get_tree().create_timer(0.18).timeout

		modulate = Color.WHITE

		await get_tree().create_timer(0.22).timeout

		taking_damage = false

		return


	# SEGUNDO HIT = MORRE

	dead = true

	$sfx/kill.play()
	$sangue.emitting = true
	$"../../../bloodSplash".impacto_kill()

	$CollisionShape2D.queue_free()
	$inimigoHitBoxL/CollisionShape2D.queue_free()
	$inimigoHitBoxR/CollisionShape2D.queue_free()

	var lado = sign(dir_ataque)

	if lado > 0:
		$AnimationPlayer.play("death1")
		velocity.x = 160
	else:
		$AnimationPlayer.play("death2")
		velocity.x = -160

	velocity.y = 0

	await get_tree().create_timer(0.25).timeout

	$"../../../ui/feed".adicionar_kill()
	$"../../..".add_score(350)

	velocity.x = 0

	await get_tree().create_timer(2).timeout

	queue_free()

func morrer_tiro(dir_ataque := 1):
	morrer_melee(dir_ataque)

func _on_inimigo_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("freezePlayer") and not body.invencivel:
		body.get_parent().gameover()
