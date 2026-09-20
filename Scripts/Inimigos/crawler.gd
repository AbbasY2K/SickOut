extends Inimigo


@export var crawler_scene: PackedScene


var state := "walk"
var state_timer := 0.0


func _ready():

	super._ready()

	WALK_SPEED = 50.0
	RUN_SPEED = 75.0

	state_timer = randf_range(1.5, 3.0)


func processar_ia(delta):

	detectar_player_crawler()

	if vendo_player:
		state = "run"

	match state:

		"run":
			run_state()

		"walk":
			walk_state(delta)

		"idle":
			idle_state(delta)


func detectar_player_crawler():

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

	if has_node("direcao"):
		$direcao.force_raycast_update()

	if has_node("pe1"):
		$pe1.force_raycast_update()

	if has_node("pe2"):
		$pe2.force_raycast_update()

	if has_node("direcao") \
	and $direcao.is_colliding() \
	and turn_timer <= 0:

		virar()

	if has_node("pe1") \
	and not $pe1.is_colliding() \
	and turn_timer <= 0:

		virar()

	if has_node("pe2") \
	and not $pe2.is_colliding() \
	and turn_timer <= 0:

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


func morrer_melee(_dir_ataque := 0.0):

	return


func morrer_tiro(_dir_ataque := 1.0):

	if dead:
		return

	dead = true
	pausar_fisica = true

	var nova_direcao := -1

	if velocity.x > 0:
		nova_direcao = 1

	desativar_colisoes_morte()

	registrar_kill(200)

	if crawler_scene == null:

		queue_free()

		return

	var crawler = crawler_scene.instantiate()

	get_parent().add_child(crawler)

	crawler.global_position = global_position + Vector2(0, 2)
	crawler.direction = nova_direcao

	queue_free()


func _on_hit_box_body_entered(body):

	if body.has_method("freezePlayer") and not body.invencivel:

		body.get_parent().gameover()
