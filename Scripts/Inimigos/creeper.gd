extends CharacterBody2D

var WALK_SPEED := 35.0
var RUN_SPEED := 60.0

var direction := -1
var turn_cooldown := 0.2
var turn_timer := 0.0

var state := "walk"
var state_timer := 0.0

var vendo_player := false
var player = null

var exploding := false
var exploded := false
var gas_mode := false

const EXPLOSION_DELAY := 0.75

func _ready():
	direction = -1
	$Sprite2D.flip_h = direction > 0

	turn_timer = turn_cooldown
	state_timer = randf_range(1.5, 3.0)

	add_to_group("inimigo")

	$gas.hide()
	$gas/CollisionShape2D.set_deferred("disabled", true)

func _physics_process(delta):

	if exploding or exploded or gas_mode:
		return

	turn_timer -= delta

	if not is_on_floor():
		velocity += get_gravity() * delta

	detectar_player()

	if vendo_player:
		state = "run"

	match state:
		"run":
			run_state()
		"walk":
			walk_state(delta)
		"idle":
			idle_state(delta)

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)

		if col:
			var normal = col.get_normal()

			if abs(normal.x) > 0.9 and turn_timer <= 0:
				virar()

func detectar_player():
	var bodies = $visao.get_overlapping_bodies()

	for body in bodies:
		if body.name == "player":
			vendo_player = true
			player = body
			return

	vendo_player = false
	player = null

	if state == "run":
		state = "idle"
		state_timer = 1.2

func walk_state(delta):

	if $AnimationPlayer.current_animation != "walk":
		$AnimationPlayer.play("walk")

	velocity.x = WALK_SPEED * direction

	state_timer -= delta

	$direcao.force_raycast_update()
	$pe1.force_raycast_update()
	$pe2.force_raycast_update()

	if $direcao.is_colliding() and turn_timer <= 0:
		virar()

	if not $pe1.is_colliding() and turn_timer <= 0:
		virar()

	if not $pe2.is_colliding() and turn_timer <= 0:
		virar()

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

	if $AnimationPlayer.current_animation != "walk":
		$AnimationPlayer.play("walk")

	if player == null:
		return

	var dir = sign(player.global_position.x - global_position.x)

	if dir != 0 and dir != direction and turn_timer <= 0:
		virar()

	velocity.x = RUN_SPEED * direction

func virar():
	direction *= -1
	$Sprite2D.flip_h = direction > 0
	turn_timer = turn_cooldown

func explodir():
	if exploding or exploded:
		return

	exploding = true
	velocity = Vector2.ZERO

	$AnimationPlayer.play("explosion")
	$sfx/fusing.play()

	# Explosão acontece aos 0.8s
	await get_tree().create_timer(0.8).timeout

	exploded = true

	for body in $explodeRange.get_overlapping_bodies():
		if body.has_method("freezePlayer") and not body.invencivel:
			body.get_parent().gameover()

	$sfx/fusing.stop()
	$sfx/explosion.play()

	$sangue.emitting = true
	$"../../../bloodSplash".impacto_kill()

	$"../../../ui/feed".adicionar_kill()
	$"../../..".add_score(250)

	# Espera completar 2 segundos desde o início
	await get_tree().create_timer(1.2).timeout

	virar_gas()

func virar_gas():

	gas_mode = true

	$Sprite2D.scale = Vector2.ONE
	$Sprite2D.position.y = 1
	$Sprite2D.modulate = Color.WHITE

	$explodeRange.monitoring = false
	$explodeRange/CollisionShape2D.set_deferred("disabled", true)

	$Sprite2D.hide()

	$CollisionShape2D.set_deferred("disabled", true)

	$hitBox.monitoring = false
	$visao.monitoring = false

	$gas.show()
	$gas/CollisionShape2D.set_deferred("disabled", false)

func morrer(_dir_ataque := 0.0):
	explodir()

func _on_explode_range_body_entered(body):

	if exploding or exploded:
		return

	if body.name == "player":
		explodir()

func _on_hit_box_body_entered(body):

	if body.has_method("freezePlayer") and not body.invencivel:
		body.get_parent().gameover()

func _on_gas_body_entered(body):

	if body.has_method("freezePlayer") and not body.invencivel:
		body.get_parent().gameover()
