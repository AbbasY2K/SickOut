class_name Inimigo
extends CharacterBody2D


@export var WALK_SPEED := 45.0
@export var RUN_SPEED := 100.0

@export var ACCELERATION := 700.0
@export var DECELERATION := 900.0

@export var VIDA_MAX := 1
@export var SCORE_MORTE := 200

@export var KNOCKBACK_DECAY := 900.0

@export var TURN_COOLDOWN := 0.2
@export var EDGE_TIME := 0.06

@export var VIRAR_COM_COLISAO := true


var vida := VIDA_MAX
var dead := false

var direction := -1
var turn_timer := 0.0

var player: Node2D = null
var vendo_player := false

var knockback := Vector2.ZERO

var edge_timer := 0.0

var pausar_fisica := false


func _ready():

	if has_node("ray_visao"):
		$ray_visao.add_exception(self)

	add_to_group("inimigo")

	atualizar_direcao()


func _physics_process(delta):

	if dead:

		if pausar_fisica:
			return

		velocity.y = 0
		move_and_slide()

		return

	if pausar_fisica:
		return

	turn_timer = max(turn_timer - delta, 0.0)

	aplicar_gravidade(delta)

	processar_ia(delta)

	move_and_slide()

	verificar_colisoes()


func processar_ia(_delta):
	pass


func aplicar_gravidade(delta):

	if not is_on_floor():
		velocity += get_gravity() * delta


func detectar_player():

	player = null
	vendo_player = false

	if not has_node("visao"):
		return

	for body in $visao.get_overlapping_bodies():

		if not body.is_in_group("player"):
			continue

		if has_node("ray_visao"):

			var dir = body.global_position - global_position

			$ray_visao.target_position = dir
			$ray_visao.force_raycast_update()

			if $ray_visao.is_colliding() and $ray_visao.get_collider() != body:
				continue

		player = body
		vendo_player = true

		return


func tem_chao_na_frente() -> bool:

	if not is_on_floor():
		return true

	if not has_node("pe1") or not has_node("pe2"):
		return true

	$pe1.force_raycast_update()
	$pe2.force_raycast_update()

	var pe: RayCast2D

	if direction < 0:
		pe = $pe1
	else:
		pe = $pe2

	return pe.is_colliding()


func tem_parede_na_frente() -> bool:

	if not has_node("direcao"):
		return false

	$direcao.force_raycast_update()

	return $direcao.is_colliding()


func pode_andar_para_frente() -> bool:

	if not is_on_floor():
		return true

	if tem_parede_na_frente():
		return false

	if not tem_chao_na_frente():
		return false

	return true


func virar():

	if turn_timer > 0:
		return

	direction *= -1

	atualizar_direcao()

	turn_timer = TURN_COOLDOWN
	edge_timer = 0.0


func atualizar_direcao():

	if has_node("Sprite2D"):
		$Sprite2D.flip_h = direction > 0


func andar(velocidade: float, delta: float):

	var alvo := velocidade * direction

	velocity.x = move_toward(
		velocity.x,
		alvo,
		ACCELERATION * delta
	)


func parar(delta: float):

	velocity.x = move_toward(
		velocity.x,
		0,
		DECELERATION * delta
	)


func verificar_colisoes():

	if not VIRAR_COM_COLISAO:
		return

	for i in range(get_slide_collision_count()):

		var col := get_slide_collision(i)

		if col == null:
			continue

		var normal := col.get_normal()

		if abs(normal.x) > 0.9 and turn_timer <= 0:

			virar()


func tocar_animacao(nome: String):

	if not has_node("AnimationPlayer"):
		return

	if not $AnimationPlayer.has_animation(nome):
		return

	if $AnimationPlayer.current_animation != nome:
		$AnimationPlayer.play(nome)


func aplicar_knockback(forca: Vector2):

	knockback = forca

	velocity.x = knockback.x


func ativar_efeitos_morte():

	if has_node("sfx/kill"):
		$sfx/kill.play()

	if has_node("sangue"):
		$sangue.emitting = true

	var blood_splash = get_node_or_null("../../../bloodSplash")

	if blood_splash and blood_splash.has_method("impacto_kill"):
		blood_splash.impacto_kill()


func registrar_kill(pontuacao: int):

	var feed = get_node_or_null("../../../ui/feed")

	if feed and feed.has_method("adicionar_kill"):
		feed.adicionar_kill()

	var cena = get_node_or_null("../../..")

	if cena and cena.has_method("add_score"):
		cena.add_score(pontuacao)


func desativar_colisoes_morte():

	collision_layer = 0
	collision_mask = 0

	for node in find_children("*", "CollisionShape2D", true, false):
		node.set_deferred("disabled", true)

	for node in find_children("*", "CollisionPolygon2D", true, false):
		node.set_deferred("disabled", true)

	for node in find_children("*", "Area2D", true, false):
		node.set_deferred("monitoring", false)
		node.set_deferred("monitorable", false)

	for node in find_children("*", "RayCast2D", true, false):
		node.enabled = false


func animacao_morte_curta():

	var sprite := get_node_or_null("Sprite2D") as Sprite2D

	if sprite == null:

		await get_tree().create_timer(0.18).timeout
		return

	var escala_final := sprite.scale * 0.75

	var modulate_final := sprite.modulate
	modulate_final.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		sprite,
		"scale",
		escala_final,
		0.18
	)

	tween.tween_property(
		sprite,
		"modulate",
		modulate_final,
		0.18
	)

	await tween.finished


func morrer():

	if dead:
		return

	dead = true
	pausar_fisica = false

	velocity = Vector2.ZERO
	knockback = Vector2.ZERO

	ativar_efeitos_morte()
	desativar_colisoes_morte()

	await animacao_morte_curta()

	registrar_kill(SCORE_MORTE)

	await get_tree().create_timer(0.35).timeout

	queue_free()


func morrer_melee(dir_ataque: float):

	if dead:
		return

	dead = true
	pausar_fisica = false

	ativar_efeitos_morte()
	desativar_colisoes_morte()

	var lado = sign(dir_ataque)

	if lado == 0:
		lado = 1

	if lado < 0:

		tocar_animacao("death1")
		velocity.x = -160

	elif lado > 0:

		tocar_animacao("death2")
		velocity.x = 160

	velocity.y = 0

	if not has_node("AnimationPlayer") \
	or (
		not $AnimationPlayer.has_animation("death1")
		and not $AnimationPlayer.has_animation("death2")
	):

		tocar_animacao("death")

	await get_tree().create_timer(0.25).timeout

	pausar_fisica = true
	velocity = Vector2.ZERO

	registrar_kill(SCORE_MORTE)

	await get_tree().create_timer(2.0).timeout

	queue_free()

func morrer_tiro(dir_ataque := 1.0):

	morrer_melee(dir_ataque)


func morrer_morrida():

	morrer()
