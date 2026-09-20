extends Inimigo


var state := "walk"
var state_timer := 0.0

var exploding := false
var exploded := false
var gas_mode := false

const EXPLOSION_DELAY := 0.75


func _ready():

	super._ready()

	WALK_SPEED = 35.0
	RUN_SPEED = 60.0

	turn_timer = TURN_COOLDOWN
	state_timer = randf_range(1.5, 3.0)

	$gas.hide()
	$gas/CollisionShape2D.set_deferred("disabled", true)


func processar_ia(delta):

	if exploding or exploded or gas_mode:

		pausar_fisica = true

		return

	pausar_fisica = false

	detectar_player_creeper()

	if vendo_player:
		state = "run"

	match state:

		"run":
			run_state()

		"walk":
			walk_state(delta)

		"idle":
			idle_state(delta)


func detectar_player_creeper():

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

	tocar_animacao("walk")

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

	tocar_animacao("idle")

	velocity.x = 0

	state_timer -= delta

	if state_timer <= 0:

		state = "walk"
		state_timer = randf_range(2.0, 4.0)


func run_state():

	tocar_animacao("walk")

	if player == null:
		return

	var dir = sign(
		player.global_position.x - global_position.x
	)

	if dir != 0 \
	and dir != direction \
	and turn_timer <= 0:

		virar()

	velocity.x = RUN_SPEED * direction


func explodir():

	if exploding or exploded:
		return

	exploding = true
	pausar_fisica = true
	velocity = Vector2.ZERO

	tocar_animacao("explosion")
	$sfx/fusing.play()

	await get_tree().create_timer(0.8).timeout

	exploded = true

	for body in $explodeRange.get_overlapping_bodies():

		if body.has_method("freezePlayer") and not body.invencivel:

			body.get_parent().gameover()

	$sfx/fusing.stop()
	$sfx/explosion.play()

	$sangue.emitting = true
	$"../../../bloodSplash".impacto_kill()

	registrar_kill(250)

	await get_tree().create_timer(1.2).timeout

	virar_gas()


func virar_gas():

	gas_mode = true
	pausar_fisica = true

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


func morrer_melee(_dir_ataque := 0.0):

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
