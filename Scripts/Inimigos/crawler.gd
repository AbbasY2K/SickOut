extends CharacterBody2D

@export var crawler_scene: PackedScene

var WALK_SPEED := 50.0
var RUN_SPEED := 75.0

var direction := -1
var turn_cooldown := 0.2
var turn_timer := 0.0

var state := "walk"
var state_timer := 0.0

var vendo_player := false
var player = null

var dead := false


func _ready():
	state_timer = randf_range(1.5, 3.0)

	$Sprite2D.flip_h = direction > 0

	add_to_group("inimigo")


func _physics_process(delta):
	if dead:
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

# IGNORA MELEE
func morrer_tiro(_dir_ataque := 1):

	if dead:
		return

	dead = true

	$hitBox.monitoring = false
	$visao.monitoring = false

	ativar_crawler()

func ativar_crawler():
	$"../../..".add_score(200)
	$"../../../ui/feed".adicionar_kill()

	if crawler_scene == null:
		queue_free()
		return

	var crawler = crawler_scene.instantiate()
	get_parent().add_child(crawler)

	crawler.global_position = global_position + Vector2(0, 2)

	if velocity.x > 0:
		crawler.direction = 1
	else:
		crawler.direction = -1

	queue_free()

func _on_hit_box_body_entered(body):

	if body.has_method("freezePlayer") and not body.invencivel:
		body.get_parent().gameover()
