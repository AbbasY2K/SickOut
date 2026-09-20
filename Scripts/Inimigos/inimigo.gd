extends Inimigo


var state := "walk"
var state_timer := 0.0

var EDGE_TIME_LOCAL := 0.06


func _ready():

	super._ready()

	state_timer = randf_range(1.5, 3.0)


func processar_ia(delta):

	detectar_player()

	if player:
		state = "run"

	elif state == "run":

		state = "idle"
		state_timer = 1.0

	match state:

		"run":
			run_state()

		"walk":
			walk_state(delta)

		"idle":
			idle_state(delta)


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

		if edge_timer >= EDGE_TIME_LOCAL and turn_timer <= 0:

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


func _on_inimigo_hit_box_body_entered(body: Node2D) -> void:

	if body.has_method("freezePlayer") and not body.invencivel:

		body.get_parent().gameover()
