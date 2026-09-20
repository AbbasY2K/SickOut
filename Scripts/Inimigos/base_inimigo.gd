class_name Inimigo
extends CharacterBody2D


# ============================================================
# MOVIMENTO
# ============================================================

@export var WALK_SPEED := 45.0
@export var RUN_SPEED := 100.0

@export var ACCELERATION := 700.0
@export var DECELERATION := 900.0


# ============================================================
# VIDA
# ============================================================

@export var VIDA_MAX := 2

var vida := VIDA_MAX
var dead := false


# ============================================================
# DIREÇÃO
# ============================================================

var direction := -1

@export var TURN_COOLDOWN := 0.2
var turn_timer := 0.0


# ============================================================
# PLAYER
# ============================================================

var player: Node2D = null
var vendo_player := false


# ============================================================
# KNOCKBACK
# ============================================================

var knockback := Vector2.ZERO

@export var KNOCKBACK_DECAY := 900.0


# ============================================================
# BORDA
# ============================================================

var edge_timer := 0.0

@export var EDGE_TIME := 0.06


# ============================================================
# READY
# ============================================================

func _ready():

	$ray_visao.add_exception(self)

	add_to_group("inimigo")

	atualizar_direcao()


# ============================================================
# PHYSICS BASE
# ============================================================

func _physics_process(delta):

	if dead:

		aplicar_gravidade(delta)

		move_and_slide()

		return


	turn_timer = max(turn_timer - delta, 0.0)

	aplicar_gravidade(delta)

	detectar_player()

	# O filho decide o comportamento.
	processar_ia(delta)

	move_and_slide()

	verificar_colisoes()


# ============================================================
# IA
# ============================================================

func processar_ia(_delta):
	pass


# ============================================================
# GRAVIDADE
# ============================================================

func aplicar_gravidade(delta):

	if not is_on_floor():

		velocity += get_gravity() * delta


# ============================================================
# PLAYER
# ============================================================

func detectar_player():

	player = null
	vendo_player = false

	for body in $visao.get_overlapping_bodies():

		if not body.is_in_group("player"):
			continue

		var dir = body.global_position - global_position

		$ray_visao.target_position = dir

		$ray_visao.force_raycast_update()

		if not $ray_visao.is_colliding() \
		or $ray_visao.get_collider() == body:

			player = body
			vendo_player = true

			return


# ============================================================
# CHÃO / BORDA
# ============================================================

func tem_chao_na_frente() -> bool:

	if not is_on_floor():
		return true

	$pe1.force_raycast_update()
	$pe2.force_raycast_update()

	var pe: RayCast2D

	if direction < 0:
		pe = $pe1
	else:
		pe = $pe2

	return pe.is_colliding()


# ============================================================
# PAREDE
# ============================================================

func tem_parede_na_frente() -> bool:

	$direcao.force_raycast_update()

	return $direcao.is_colliding()


# ============================================================
# PAREDE + BORDA
# ============================================================

func pode_andar_para_frente() -> bool:

	if not is_on_floor():
		return true

	if tem_parede_na_frente():
		return false

	if not tem_chao_na_frente():
		return false

	return true


# ============================================================
# VIRAR
# ============================================================

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


# ============================================================
# MOVIMENTO
# ============================================================

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


# ============================================================
# COLISÕES
# ============================================================

func verificar_colisoes():

	for i in range(get_slide_collision_count()):

		var col := get_slide_collision(i)

		if col == null:
			continue

		var normal := col.get_normal()

		if abs(normal.x) > 0.9:

			if turn_timer <= 0:

				virar()


# ============================================================
# ANIMAÇÃO
# ============================================================

func tocar_animacao(nome: String):

	if not has_node("AnimationPlayer"):
		return

	if not $AnimationPlayer.has_animation(nome):
		return

	if $AnimationPlayer.current_animation != nome:

		$AnimationPlayer.play(nome)


# ============================================================
# KNOCKBACK
# ============================================================

func aplicar_knockback(forca: Vector2):

	knockback = forca

	velocity.x = knockback.x


# ============================================================
# MORTE
# ============================================================

func morrer():

	if dead:
		return

	dead = true
