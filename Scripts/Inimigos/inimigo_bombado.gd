extends CharacterBody2D

var vida := 3

var WALK_SPEED := 55.0
var CHASE_SPEED := 150.0

var ACCEL := 700.0
var current_speed := 0.0

var direction := -1

var turn_cooldown := 0.1
var turn_timer := 0.0

var dead := false

var state := "walk"
var state_timer := 0.0

var player: Node2D = null

var attack_cooldown := 0.8
var attack_timer := 0.0

var origin_x := 0.0

@onready var sprite := $Sprite2D
@onready var anim := $AnimationPlayer

func _ready():
	state_timer = randf_range(1.0, 2.0)
	add_to_group("inimigoGrande")
	origin_x = global_position.x

func _physics_process(delta):

	if dead:
		move_and_slide()
		return

	match vida:
		1: sprite.modulate = Color(1.0, 0.25, 0.25, 1.0)
		2: sprite.modulate = Color(1.0, 0.504, 0.504, 1.0)
		_: sprite.modulate = Color.WHITE

	turn_timer = max(turn_timer - delta, 0.0)
	attack_timer = max(attack_timer - delta, 0.0)

	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		"walk": walk_state(delta)
		"idle": idle_state(delta)
		"attack": attack_state(delta)

	move_and_slide()
	check_turn()

func walk_state(delta):

	if anim.current_animation != "walk":
		anim.play("walk")

	var target_speed := WALK_SPEED

	if is_instance_valid(player):

		var diff_y = abs(player.global_position.y - global_position.y)

		if diff_y < 32.0:

			target_speed = CHASE_SPEED

			var dir = sign(player.global_position.x - global_position.x)

			if dir != 0:
				direction = dir
				sprite.flip_h = direction > 0

	current_speed = move_toward(current_speed, target_speed, ACCEL * delta)

	velocity.x = current_speed * direction

	anim.speed_scale = 2.3 if is_instance_valid(player) else 1.0

	if not is_instance_valid(player):

		var dist_patrol = global_position.x - origin_x

		if dist_patrol > 120.0 and direction > 0:
			virar()

		elif dist_patrol < -120.0 and direction < 0:
			virar()

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

	if anim.current_animation != "idle":
		anim.play("idle")

	velocity.x = move_toward(velocity.x, 0, ACCEL * delta)

	current_speed = 0

	state_timer -= delta

	if is_instance_valid(player):
		state = "walk"
		return

	if state_timer <= 0:
		state = "walk"
		state_timer = randf_range(1.0, 2.0)

func attack_state(delta):

	velocity.x = move_toward(velocity.x, 0, ACCEL * delta)

	current_speed = 0

	state_timer -= delta

	if state_timer <= 0:
		state = "walk"

func virar():
	direction *= -1
	sprite.flip_h = direction > 0
	turn_timer = turn_cooldown

func check_turn():

	for i in range(get_slide_collision_count()):

		var col = get_slide_collision(i)

		if (
			col
			and abs(col.get_normal().x) > 0.9
			and turn_timer <= 0
		):
			virar()

func morrer(_dir):

	if dead:
		return

	dead = true

	$sfx/kill.play()
	$sangue.emitting = true
	$"../../../bloodSplash".impacto_kill()
	$"../../../ui/feed".adicionar_kill()
	$"../../..".add_score(400)

	$CollisionShape2D.queue_free()
	$inimigoHitBoxL/CollisionShape2D.queue_free()
	$inimigoHitBoxR/CollisionShape2D.queue_free()
	$visaoAtaque/CollisionShape2D.queue_free()

	anim.play("death")

	velocity.x = 0

	await get_tree().create_timer(2.0).timeout

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
			await morrer(direction)

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

	state_timer = 0.9 # antes 0.7

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

	var onda_scene = preload("res://Cenas/ataque_bombadao.tscn")

	var direita = onda_scene.instantiate()
	direita.global_position = $spawner2.global_position
	direita.direction = 1
	get_parent().add_child(direita)

	var esquerda = onda_scene.instantiate()
	esquerda.global_position = $spawner1.global_position
	esquerda.direction = -1
	get_parent().add_child(esquerda)

	var cam = get_tree().get_current_scene().get_node_or_null("player/Camera2D")

	if cam:
		cam.shake(0.25, 1.5)
