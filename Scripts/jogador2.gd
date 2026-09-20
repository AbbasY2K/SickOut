extends CharacterBody2D

# ======================
# CONSTS
# ======================
const SPEED = 300.0
const ACCELERATION = 2000.0
const FRICTION = 700.0
const JUMP_VELOCITY = -400.0

const DASH_SPEED = 600.0
const DASH_TIME = 0.15
const DASH_COOLDOWN = 0.4

# ======================
# VARS
# ======================
var vida = 3

var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := 0.0

# ======================
# PHYSICS
# ======================
func _physics_process(delta):

	# Timers
	if dash_timer > 0:
		dash_timer -= delta
	else:
		is_dashing = false

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Gravidade
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dashing:
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")

	# DASH
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing:
		if direction == 0:
			direction = sign(velocity.x)
		if direction != 0:
			is_dashing = true
			dash_timer = DASH_TIME
			dash_cooldown_timer = DASH_COOLDOWN
			dash_direction = direction

	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
	else:
		# Movimento normal com aceleração
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	move_and_slide()
