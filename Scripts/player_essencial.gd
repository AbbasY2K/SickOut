extends CharacterBody2D

const SPEED = 180.0
const ACCELERATION = 1000.0
const FRICTION = 700.0
const JUMP_VELOCITY = -420.0
const GRAVITY = 1350

const DASH_SPEED = 275.0
const DASH_TIME = 0.35
const DASH_COOLDOWN = 0.35

const MAX_STAMINA := 100.0
const DASH_STAMINA_COST := 45.0
const STAMINA_RECOVER_SPEED := 35.0

var stamina := MAX_STAMINA

const MELEE_TIME = 0.46

const MELEE_HIT_START = 0.05
const MELEE_HIT_END = 0.28

const MELEE_COOLDOWN = 0.06
const MELEE_BUFFER_TIME := 0.16

const RUN_SHOOT_SLOW_FACTOR = 0.65
const KNOCKBACK_DECAY = 3200.0

const MAX_AMMO := 6
const MAX_PULOS = 2

const CAMERA_LOOK_DISTANCE := 80.0
const CAMERA_LOOK_SMOOTH := 13.0
const CAMERA_DEADZONE := 0.15

var cameraOffset := Vector2.ZERO

var meleeCooldown := 0.0
var meleeBuffer := 0.0
var pulos = 0
var ammo := MAX_AMMO

var dashTime := 0.0
var dashCooldown := 0.0
var dashDir := 0.0

var meleeing := false
var meleeTimer := 0.0
var meleeNum := 1

var knockback := Vector2.ZERO
var facingDir := 1
var currentState := ""
var wasOnFloor := false
var invencivel = false

var voiceCooldown := 0.0
const VOICE_DELAY_MIN := 0.4
const VOICE_DELAY_MAX := 1.2
const VOICE_CHANCE := 0.6

var airDashUsed = false
var airShootStop := 0.0

const WALL_SLIDE_SPEED = 80.0
const WALL_JUMP_FORCE_X = 270.0
const WALL_JUMP_FORCE_Y = -430.0
const WALL_JUMP_STAMINA_COST := 28.0

var wallJumpLocked = false

const GHOST_INTERVAL = 0.06

var ghostTimer := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var mira: Node2D = $mira
@onready var bulletSpawner: Node2D = $mira/balaSpawner
@onready var areaSoco: Area2D = $areaSoco
@onready var bulletScene = preload("res://Cenas/tiro.tscn")
@onready var ganchoCamera = $ganchoCamera

@onready var pe1 = $pe1
@onready var pe2 = $pe2
@onready var collision = $CollisionShape2D
@onready var camera = $"../Camera2D"

var cameraTarget: Node2D = null
var cameraTargetOffset := Vector2.ZERO

var diretor_ativo := false

var diretor_direcao := 0.0
var diretor_atirar := false
var diretor_dash := false
var diretor_pular := false
var diretor_melee := false

@onready var ammoIcons := [
	$"../ui/municao/icones/dardo1",
	$"../ui/municao/icones/dardo2",
	$"../ui/municao/icones/dardo3",
	$"../ui/municao/icones/dardo4",
	$"../ui/municao/icones/dardo5",
	$"../ui/municao/icones/dardo6"
]

var baseSocoPos: Vector2

func _ready():
	add_to_group("player")
	baseSocoPos = $areaSoco/CollisionShape2D.position
	areaSoco.monitoring = false
	
	updateUi()

func _physics_process(delta):
	updateTimers(delta)

	var inputData = getInput()

	updateFacing(inputData)
	processDash(inputData)
	processMelee(inputData, delta)
	processMovement(inputData, delta)
	applyGravity(delta)
	processJump()
	applyKnockback(delta)
	processShoot(inputData)

	updateCameraLook(delta)

	move_and_slide()

	airShootStop = max(airShootStop - delta, 0.0)

	stamina = min(
	stamina + STAMINA_RECOVER_SPEED * delta,
	MAX_STAMINA
	)

	if dashTime > 0:
		ghostTimer -= delta

		if ghostTimer <= 0:
			ghostTimer = GHOST_INTERVAL
			spawnGhost()
	else:
		ghostTimer = 0.0

	if not wasOnFloor and is_on_floor():
		$sfx/land.play()
		pulos = 0
		airDashUsed = false

	wasOnFloor = is_on_floor()

	if is_on_floor():
		wallJumpLocked = false
	
	if !is_on_wall_custom():
		wallJumpLocked = false

	updateAnimation(inputData)

func getInput():

	if diretor_ativo:

		var inputData = {
			"direction": diretor_direcao,
			"shootPressed": diretor_atirar and ammo > 0,
			"shootJust": diretor_atirar,
			"dash": diretor_dash,
			"jump": diretor_pular,
			"melee": diretor_melee
		}

		# Inputs de um único frame
		diretor_atirar = false
		diretor_dash = false
		diretor_pular = false
		diretor_melee = false

		return inputData


	return {
		"direction": Input.get_axis("left", "right"),
		"shootPressed": Input.is_action_pressed("shoot") and ammo > 0,
		"shootJust": Input.is_action_just_pressed("shoot"),
		"dash": Input.is_action_just_pressed("dash"),
		"jump": Input.is_action_just_pressed("jump"),
		"melee": Input.is_action_just_pressed("melee")
	}

func updateCameraLook(delta):

	if cameraTarget:
		ganchoCamera.global_position = (
			cameraTarget.global_position +
			cameraTargetOffset
		)
		return

	var lookInput := Vector2(
		Input.get_axis("look_left", "look_right"),
		Input.get_axis("look_up", "look_down")
	)

	# Se estiver usando controle, prioriza o analógico direito
	var joyInput := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)

	if joyInput.length() > CAMERA_DEADZONE:
		lookInput = joyInput

	var targetOffset = lookInput.normalized() * CAMERA_LOOK_DISTANCE

	if lookInput == Vector2.ZERO:
		targetOffset = Vector2.ZERO

	cameraOffset = cameraOffset.lerp(
		targetOffset,
		CAMERA_LOOK_SMOOTH * delta
	)

	ganchoCamera.position = cameraOffset

func updateFacing(inputData):

	if dashTime > 0 or meleeing:
		return

	if inputData.direction != 0 and not inputData.shootPressed:
		facingDir = sign(inputData.direction)

func updateTimers(delta):
	dashTime = max(dashTime - delta, 0)
	dashCooldown = max(dashCooldown - delta, 0)
	meleeCooldown = max(meleeCooldown - delta, 0)
	meleeBuffer = max(meleeBuffer - delta, 0)
	voiceCooldown = max(voiceCooldown - delta, 0)

	if dashTime == 0:
		invencivel = false

func processDash(inputData):
	if meleeing:
		return

	if inputData.dash and dashCooldown <= 0 and stamina >= DASH_STAMINA_COST:

		if not is_on_floor():

			if airDashUsed:
				return

			airDashUsed = true

		dashDir = inputData.direction if inputData.direction != 0 else facingDir

		dashTime = DASH_TIME
		dashCooldown = DASH_COOLDOWN
		stamina -= DASH_STAMINA_COST

		if is_on_floor():
			invencivel = true
		else:
			invencivel = false

		velocity.y *= 0.45

		if not is_on_floor():
			collision.disabled = false
		else:
			collision.disabled = true

		anim.play("dash")

		$sfx/dash.play()

		$sfx/land.volume_db = -90

		await get_tree().create_timer(0.46).timeout

		$sfx/land.volume_db = 2

	if dashTime > 0:

		var targetRotation = 15 * dashDir

		sprite.rotation_degrees = move_toward(
			sprite.rotation_degrees,
			targetRotation,
			1200 * get_physics_process_delta_time()
		)

		if $peito1.is_colliding() or $peito2.is_colliding():

			dashTime = 0

			velocity.x = 0

			return

		velocity.x = dashDir * DASH_SPEED

	else:

		collision.disabled = false

		sprite.rotation_degrees = move_toward(
			sprite.rotation_degrees,
			0,
			900 * get_physics_process_delta_time()
		)

func processMelee(inputData, delta):
	if inputData.melee:
		meleeBuffer = MELEE_BUFFER_TIME

	if meleeBuffer > 0 and not meleeing and meleeCooldown <= 0 and dashTime <= 0:
		meleeing = true
		meleeTimer = 0
		meleeCooldown = MELEE_COOLDOWN
		meleeBuffer = 0

		anim.stop()

		if meleeNum == 1:
			anim.play("melee1")
			meleeNum = 2
		else:
			anim.play("melee2")
			meleeNum = 1

		$sfx/melee.play()
		playVoiceLine()

	if not meleeing:
		return

	meleeTimer += delta

	if meleeTimer < MELEE_HIT_START:
		velocity.x = move_toward(velocity.x, 0, 2500 * delta)

	elif meleeTimer < MELEE_HIT_END:
		var targetSpeed = facingDir * 260
		velocity.x = move_toward(velocity.x, targetSpeed, 4000 * delta)
		areaSoco.monitoring = true

	else:
		velocity.x = move_toward(velocity.x, 0, 2200 * delta)
		areaSoco.monitoring = false

	if meleeTimer >= MELEE_TIME:
		meleeing = false
		meleeTimer = 0
		anim.play("idle")
		changeState("idle")

func processMovement(inputData, delta):
	if meleeing or dashTime > 0:
		return

	if knockback.length() > 5:
		return

	const DEADZONE := 0.3

	var direction = inputData.direction

	# Deadzone + remapeamento
	if abs(direction) < DEADZONE:
		direction = 0.0
	else:
		direction = sign(direction) * ((abs(direction) - DEADZONE) / (1.0 - DEADZONE))

	if direction != 0:
		var targetSpeed = SPEED

		if inputData.shootPressed and is_on_floor():
			targetSpeed *= RUN_SHOOT_SLOW_FACTOR

		velocity.x = move_toward(
			velocity.x,
			direction * targetSpeed,
			ACCELERATION * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			FRICTION * delta
		)

func applyGravity(delta):
	if airShootStop > 0:
		return

	if dashTime == 0 and not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if !is_on_floor() and is_on_wall_custom() and velocity.y > 0:
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)

		if $paredeEsq.is_colliding():
			facingDir = -1

		if $paredeDir.is_colliding():
			facingDir = 1

func is_on_wall_custom():
	return $paredeEsq.is_colliding() or $paredeDir.is_colliding()

func processJump():
	if (
		Input.is_action_just_pressed("jump")
		and !is_on_floor()
		and is_on_wall_custom()
		and !wallJumpLocked
		and stamina >= WALL_JUMP_STAMINA_COST
	):
		velocity.y = WALL_JUMP_FORCE_Y

		if $paredeEsq.is_colliding():
			velocity.x = WALL_JUMP_FORCE_X
			stamina -= WALL_JUMP_STAMINA_COST
			facingDir = 1
		else:
			velocity.x = -WALL_JUMP_FORCE_X
			stamina -= WALL_JUMP_STAMINA_COST
			facingDir = -1

		wallJumpLocked = true
		pulos = 2
		$sfx/walljump.play()
		return
	
	if meleeing or dashTime > 0:
		return

	if Input.is_action_just_pressed("jump") and pulos < MAX_PULOS:
		pulos += 1

		if pulos == 1:
			$sfx/jump.play()
			velocity.y = JUMP_VELOCITY

		elif pulos == 2:
			$sfx/jump2.play()
			velocity.y = JUMP_VELOCITY * 0.7

func applyKnockback(delta):
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)

func processShoot(inputData):
	if meleeing or dashTime > 0:
		return

	if ammo <= 0:
		return

	if inputData.shootJust:
		if inputData.direction != 0:
			changeState("runShoot")
		else:
			changeState("shoot")

func shoot():
	if ammo <= 0:
		return

	ammo -= 1
	updateUi()
	Input.start_joy_vibration(0, 0.5, 1.0, 0.185)

	var bullet = bulletScene.instantiate()

	get_tree().current_scene.add_child(bullet)

	bullet.global_position = bulletSpawner.global_position
	bullet.direction = Vector2(facingDir, 0)

	if not is_on_floor():
		airShootStop = 0.12 # cerca de 5 frames a 60 FPS
		velocity.y = 0
		$AnimationPlayer.play("tiroPulo")
	
	$sfx/shoot.play()

	playVoiceLine()

	$"../Camera2D".shake(0.3, 3)

	if $"../ui/municao/AnimationPlayer".is_playing():
		$"../ui/municao/AnimationPlayer".seek(0.25, true)
	else:
		$"../ui/municao/AnimationPlayer".play("in")

func updateAnimation(inputData):
	sprite.flip_h = facingDir < 0
	mira.scale.x = -1 if facingDir < 0 else 1

	# Inverte posição e direção da poeira
	if facingDir < 0:
		$poeira.position.x *= -1
		$poeira.scale.x = -1
	else:
		$poeira.position.x *= -1
		$poeira.scale.x = 1

	$areaSoco/CollisionShape2D.position.x = abs(baseSocoPos.x) * facingDir
	$areaSoco/CollisionShape2D.position.y = baseSocoPos.y

	if dashTime > 0:
		changeState("dash")
		return

	if meleeing:
		return

	var isRunning = inputData.direction != 0 and is_on_floor()
	var isShooting = inputData.shootPressed and ammo > 0

	if currentState == "shoot" and anim.is_playing():
		return

	var newState = ""

	if isShooting and is_on_floor():
		newState = "runShoot" if isRunning else "idleArmado"
	else:
		if is_on_floor():
			newState = "run" if isRunning else "idle"
		else:
			newState = "jump" if velocity.y < 0 else "fall"

	changeState(newState)

func changeState(newState):
	if currentState == newState:
		return

	currentState = newState
	anim.play(newState)
	
	if newState == "run":
		$poeira.emitting = true
		$sfx/walk/AnimationPlayer.play("idle")
	else:
		$poeira.emitting = false
		$sfx/walk/AnimationPlayer.stop()

func spawnGhost():
	var ghost := Sprite2D.new()

	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame

	ghost.flip_h = sprite.flip_h
	ghost.centered = sprite.centered
	ghost.offset = sprite.offset

	ghost.global_position = sprite.global_position
	ghost.global_rotation = sprite.global_rotation
	ghost.global_scale = sprite.global_scale

	ghost.modulate = Color(1, 1, 1, 0.6)

	get_parent().add_child(ghost)

	var tween := create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.22)
	tween.finished.connect(ghost.queue_free)

func regenerateAmmo():
	if ammo >= MAX_AMMO:
		return

	ammo = min(ammo + 2, MAX_AMMO)

	updateUi()

	if $"../ui/municao/AnimationPlayer".is_playing():
		$"../ui/municao/AnimationPlayer".seek(0.25, true)
	else:
		$"../ui/municao/AnimationPlayer".play("in")

	$sfx/reloadFull.play()

func updateUi():
	for i in range(MAX_AMMO):
		if i < ammo:
			ammoIcons[i].modulate = Color(1, 1, 1, 1)
		else:
			ammoIcons[i].modulate = Color(0.3, 0.3, 0.3, 0.5)

func _on_area_soco_body_entered(body):

	var inimigo = body
	var direcao_ataque = 1 if not $Sprite2D.flip_h else -1

	while inimigo:
		if inimigo.has_method("morrer_melee"):
			inimigo.morrer_melee(direcao_ataque)
			return

		if inimigo.has_method("morrer"):
			inimigo.morrer(direcao_ataque)
			return

		inimigo = inimigo.get_parent()

func playVoiceLine():
	if voiceCooldown > 0:
		return

	if randf() > VOICE_CHANCE:
		return

	var falas = [$sfx/fala1, $sfx/fala2]
	var falaEscolhida = falas.pick_random()

	falaEscolhida.stop()
	falaEscolhida.pitch_scale = randf_range(0.9, 1.1)
	falaEscolhida.play()

	voiceCooldown = randf_range(
		VOICE_DELAY_MIN,
		VOICE_DELAY_MAX
	)

func freezePlayer():
	velocity = Vector2.ZERO
	knockback = Vector2.ZERO
	dashTime = 0
	meleeing = false

	collision.set_deferred("disabled", true)

	anim.play("idle")
	$sfx/walk/AnimationPlayer.stop()

	set_process(false)
	set_physics_process(false)

func unfreezePlayer():
	collision.disabled = false

	changeState("idle")

	set_process(true)
	set_physics_process(true)
