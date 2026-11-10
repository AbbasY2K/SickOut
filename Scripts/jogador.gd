
extends CharacterBody2D

const MAX_LIVES := 2
var lives: int = 1

const SPEED = 180
const ACCELERATION = 1400.0
const FRICTION = 975.0
const JUMP_VELOCITY = -420.0
const GRAVITY = 1350.0

const TOXICIDADE_MAXIMA := 100.0

var toxicidade := 0.0
var recuperacaoToxicidade := 20.0
var dentroAreaToxica := false

# OVERDOSE
const OVERDOSE_DURATION := 7.0
const OVERDOSE_WORLD_SCALE := 0.2
const OVERDOSE_PLAYER_BOOST := 1.2
const OVERDOSE_TRANSITION_TIME := 0.16
const OVERDOSE_ANIM_SPEED := 0.9
const OVERDOSE_GHOST_INTERVAL := 0.055
const OVERDOSE_GHOST_OPACITY := 0.68
const OVERDOSE_GHOST_FADE := 0.24
const OVERDOSE_SCENE_DARKEN := Color(0.38, 0.34, 0.48, 1.0)

var overdoseActive := false
var overdoseToken := 0
var overdoseSceneTween: Tween = null

var overdoseSceneNodes: Array[CanvasItem] = []
var overdoseOriginalColors: Array[Color] = []

var overdoseOriginalAnimSpeed := 1.0
var overdoseOriginalMusicPitch := 1.0
var overdoseOriginalShaderVisible := false

var overdoseMusic: AudioStreamPlayer = null

var overdoseOriginalCameraPositionSpeed := 0.0
var overdoseOriginalCameraRotationSpeed := 0.0

# DASH
const DASH_SPEED = 340.0
const DASH_TIME = 0.24
const DASH_COOLDOWN = 0.45

const MAX_STAMINA := 100.0
const DASH_STAMINA_COST := 45.0
const STAMINA_RECOVER_SPEED := 40.0

const DAMAGE_INVINCIBILITY_TIME := 1.15
const DAMAGE_BLINK_INTERVAL := 0.08

const DAMAGE_KNOCKBACK_SPEED := 340.0
const DAMAGE_KNOCKBACK_UP := -160.0
const DAMAGE_MOVEMENT_LOCK := 0.24

var damageKnockbackTimer := 0.0

var damageInvulnerabilityTimer := 0.0
var damageBlinkTimer := 0.0
var damageBlinkState := false

# CONTROLE
const INPUT_DEADZONE := 0.25
const COYOTE_TIME := 0.10
const JUMP_BUFFER_TIME := 0.12

# TIRO NO AR
const AIR_SHOOT_MAX_DRIFT := 35.0

var AIR_SHOOT_BRAKE := 0.2
var AIR_SHOOT_STOP := 0.0

var coyoteTimer := 0.0
var jumpBufferTimer := 0.0

var stamina := MAX_STAMINA

const MELEE_TIME = 0.46

const MELEE_HIT_START = 0.05
const MELEE_HIT_END = 0.28

const MELEE_COOLDOWN = 0.10
const MELEE_BUFFER_TIME := 0.18

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
var wasShooting := false

var voiceCooldown := 0.0
const VOICE_DELAY_MIN := 0.4
const VOICE_DELAY_MAX := 1.2
const VOICE_CHANCE := 0.6

var airDashUsed = false
var airShootStop := 0.0

const WALL_SLIDE_SPEED = 80.0
const WALL_JUMP_FORCE_X = 220.0
const WALL_JUMP_FORCE_Y = -460.0
const WALL_JUMP_STAMINA_COST := 28.0

var wallJumpLocked = false

const KILL_STREAK_WINDOW := 3.0

var killStreak := 0
var killStreakTimer := 0.0

var killHitstopActive := false
var killHitstopScale := 1.0
var killHitstopToken := 0

const GHOST_INTERVAL := 0.06

var ghostTimer := 0.0

const RUN_SHOOT_EXIT_DELAY := 0.15
var runShootExitTimer := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var mira: Node2D = $mira
@onready var bulletSpawner: Node2D = $mira/balaSpawner
@onready var areaSoco: Area2D = $areaSoco
@onready var bulletScene = preload("res://Cenas/tiro.tscn")
@onready var ganchoCamera = $ganchoCamera
@onready var livesUI = get_tree().current_scene.get_node_or_null("ui")
@onready var toxicOverlay: ColorRect = get_node_or_null("../ui/toxico") as ColorRect

@onready var pe1 = $pe1
@onready var pe2 = $pe2
@onready var collision = $CollisionShape2D
@onready var camera = $ganchoCamera/Camera2D

@onready var overdoseShader: CanvasItem = get_node_or_null("../shaderOverdose/ColorRect") as CanvasItem

var cameraTarget: Node2D = null
var cameraTargetOffset := Vector2.ZERO

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

	overdoseOriginalAnimSpeed = anim.speed_scale

	if is_instance_valid(overdoseShader):
		overdoseOriginalShaderVisible = overdoseShader.visible

	var cenaAtual := get_tree().current_scene

	if cenaAtual != null:
		overdoseMusic = cenaAtual.get_node_or_null("sfx/music") as AudioStreamPlayer

	if is_instance_valid(overdoseMusic):
		overdoseOriginalMusicPitch = overdoseMusic.pitch_scale

	if is_instance_valid(camera):
		overdoseOriginalCameraPositionSpeed = camera.position_smoothing_speed
		overdoseOriginalCameraRotationSpeed = camera.rotation_smoothing_speed

	registrar_cenario_overdose()

	updateUi()


func _exit_tree():
	overdoseActive = false
	overdoseToken += 1

	killHitstopToken += 1
	killHitstopActive = false
	killHitstopScale = 1.0

	if overdoseSceneTween != null and is_instance_valid(overdoseSceneTween):
		overdoseSceneTween.kill()

	if is_instance_valid(overdoseMusic):
		overdoseMusic.pitch_scale = overdoseOriginalMusicPitch

	if is_instance_valid(overdoseShader):
		overdoseShader.visible = overdoseOriginalShaderVisible

	if is_instance_valid(anim):
		anim.speed_scale = overdoseOriginalAnimSpeed

	transicionar_cenario_overdose(false, false)

	atualizar_escala_tempo()


func _physics_process(delta):
	var playerDelta = delta

	if overdoseActive:
		playerDelta /= OVERDOSE_WORLD_SCALE

	updateTimers(playerDelta)
	ativar_inimigos_proximos()

	var inputData = getInput()

	if is_on_floor():
		coyoteTimer = COYOTE_TIME
	else:
		coyoteTimer = max(coyoteTimer - playerDelta, 0.0)

	if inputData.jump:
		jumpBufferTimer = JUMP_BUFFER_TIME
	else:
		jumpBufferTimer = max(jumpBufferTimer - playerDelta, 0.0)

	updateFacing(inputData)

	processDash(inputData, playerDelta)
	processMelee(inputData, playerDelta)
	processMovement(inputData, playerDelta)
	applyGravity(playerDelta)
	processJump(inputData)
	applyKnockback(playerDelta)
	processShoot(inputData)

	updateCameraLook(playerDelta)

	if overdoseActive:
		var fatorMovimento := OVERDOSE_PLAYER_BOOST / OVERDOSE_WORLD_SCALE

		velocity *= fatorMovimento
		move_and_slide()
		velocity /= fatorMovimento
	else:
		move_and_slide()

	airShootStop = max(airShootStop - playerDelta, 0.0)

	stamina = min(
		stamina + STAMINA_RECOVER_SPEED * playerDelta,
		MAX_STAMINA
	)

	if not dentroAreaToxica and toxicidade > 0:
		toxicidade = maxf(
			toxicidade - recuperacaoToxicidade * playerDelta,
			0.0
		)
	atualizarToxicidadeVisual()

	var deveCriarGhost := dashTime > 0

	if overdoseActive and velocity.length() > 30.0:
		deveCriarGhost = true

	if deveCriarGhost:
		ghostTimer -= playerDelta

		if ghostTimer <= 0:
			if overdoseActive:
				ghostTimer = OVERDOSE_GHOST_INTERVAL
			else:
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


# OVERDOSE

func registrar_cenario_overdose() -> void:
	var caminhos := [
		"../tileSet3",
		"../tileSet",
		"../tileSet4",
		"../parallaxBg",
		"../elementos/portas"
	]

	for caminho in caminhos:
		var elemento := get_node_or_null(caminho)

		if elemento != null:
			registrar_elemento_cenario(elemento)


func registrar_elemento_cenario(node: Node) -> void:
	if node is CanvasItem:
		var item := node as CanvasItem

		if not overdoseSceneNodes.has(item):
			overdoseSceneNodes.append(item)
			overdoseOriginalColors.append(item.modulate)

		return

	for filho in node.get_children():
		registrar_elemento_cenario(filho)


func ativar_overdose() -> void:
	if not overdoseActive:
		overdoseActive = true
		configurar_camera_overdose(true)

		if killHitstopActive:
			killHitstopToken += 1
			killHitstopActive = false
			killHitstopScale = 1.0

		anim.speed_scale = OVERDOSE_ANIM_SPEED / OVERDOSE_WORLD_SCALE

		if is_instance_valid(overdoseShader):
			overdoseShader.visible = true

		if is_instance_valid(overdoseMusic):
			overdoseMusic.pitch_scale = 1.1

		$"../shaderOverdose".show()

		transicionar_cenario_overdose(true)

		atualizar_escala_tempo()

	overdoseToken += 1
	var token := overdoseToken

	await get_tree().create_timer(
		OVERDOSE_DURATION,
		true,
		false,
		true
	).timeout

	if token != overdoseToken or not overdoseActive:
		return

	$"../shaderOverdose".hide()

	encerrar_overdose()


func encerrar_overdose(transicao: bool = true) -> void:
	if not overdoseActive:
		return

	overdoseActive = false
	configurar_camera_overdose(false)
	overdoseToken += 1

	if killHitstopActive:
		killHitstopToken += 1
		killHitstopActive = false
		killHitstopScale = 1.0

	if is_instance_valid(anim):
		anim.speed_scale = overdoseOriginalAnimSpeed

	if is_instance_valid(overdoseMusic):
		overdoseMusic.pitch_scale = overdoseOriginalMusicPitch

	if is_instance_valid(overdoseShader):
		overdoseShader.visible = overdoseOriginalShaderVisible

	transicionar_cenario_overdose(false, transicao)

	atualizar_escala_tempo()

func configurar_camera_overdose(ativa: bool) -> void:
	if not is_instance_valid(camera):
		return

	if ativa:
		camera.position_smoothing_speed = (
			overdoseOriginalCameraPositionSpeed / OVERDOSE_WORLD_SCALE
		)

		camera.rotation_smoothing_speed = (
			overdoseOriginalCameraRotationSpeed / OVERDOSE_WORLD_SCALE
		)
	else:
		camera.position_smoothing_speed = overdoseOriginalCameraPositionSpeed
		camera.rotation_smoothing_speed = overdoseOriginalCameraRotationSpeed

func transicionar_cenario_overdose(
	ativar: bool,
	usarTween: bool = true
) -> void:

	if overdoseSceneTween != null and is_instance_valid(overdoseSceneTween):
		overdoseSceneTween.kill()

	if usarTween and is_inside_tree():
		overdoseSceneTween = create_tween()
		overdoseSceneTween.set_ignore_time_scale(true)
		overdoseSceneTween.set_parallel(true)

		for i in range(overdoseSceneNodes.size()):
			var elemento := overdoseSceneNodes[i]

			if not is_instance_valid(elemento):
				continue

			var corOriginal := overdoseOriginalColors[i]
			var corDestino: Color

			if ativar:
				corDestino = corOriginal * OVERDOSE_SCENE_DARKEN
			else:
				corDestino = corOriginal

			overdoseSceneTween.tween_property(
				elemento,
				"modulate",
				corDestino,
				OVERDOSE_TRANSITION_TIME
			)
	else:
		overdoseSceneTween = null

		for i in range(overdoseSceneNodes.size()):
			var elemento := overdoseSceneNodes[i]

			if not is_instance_valid(elemento):
				continue

			elemento.modulate = overdoseOriginalColors[i]


func getInput():
	return {
		"direction": Input.get_axis("left", "right"),
		"shootPressed": Input.is_action_pressed("shoot"),
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

	damageInvulnerabilityTimer = maxf(
		damageInvulnerabilityTimer - delta,
		0.0
	)

	damageKnockbackTimer = maxf(
		damageKnockbackTimer - delta,
		0.0
	)

	if damageInvulnerabilityTimer > 0.0:
		invencivel = true
		damageBlinkTimer -= delta

		if damageBlinkTimer <= 0:
			damageBlinkTimer = DAMAGE_BLINK_INTERVAL
			damageBlinkState = not damageBlinkState

			if damageBlinkState:
				sprite.modulate = Color(1, 0.4, 0.4, 0.45)
			else:
				sprite.modulate = Color.WHITE

	elif dashTime <= 0:
		invencivel = false
		sprite.modulate = Color.WHITE

	runShootExitTimer = max(runShootExitTimer - delta, 0)

	# TIMER DA KILL STREAK
	if killStreakTimer > 0.0:
		killStreakTimer = max(killStreakTimer - delta, 0.0)

		if killStreakTimer <= 0.0:
			killStreak = 0


func registrar_kill_streak() -> int:
	if killStreakTimer > 0.0:
		killStreak = mini(killStreak + 1, 3)
	else:
		killStreak = 1

	killStreakTimer = KILL_STREAK_WINDOW

	aplicar_impacto_kill(killStreak)

	return killStreak


func aplicar_impacto_kill(nivel: int) -> void:
	var shakeDuracao := 0.12
	var shakeForca := 2.0

	var hitstopDuracao := 0.025
	var hitstopEscala := 0.14

	match nivel:
		2:
			shakeDuracao = 0.21
			shakeForca = 4.3
			hitstopDuracao = 0.040
			hitstopEscala = 0.09

		3:
			shakeDuracao = 0.32
			shakeForca = 6.8
			hitstopDuracao = 0.055
			hitstopEscala = 0.045

	if is_instance_valid(camera) and camera.has_method("shake"):
		camera.shake(shakeDuracao, shakeForca)

	aplicar_hitstop_kill(hitstopDuracao, hitstopEscala)


func aplicar_hitstop_kill(duracao: float, escala: float) -> void:
	if overdoseActive:
		return

	if killHitstopActive:
		killHitstopScale = minf(killHitstopScale, escala)
		atualizar_escala_tempo()
		return

	killHitstopActive = true
	killHitstopScale = escala

	killHitstopToken += 1
	var token := killHitstopToken

	atualizar_escala_tempo()

	await get_tree().create_timer(
		duracao,
		true,
		false,
		true
	).timeout

	if token != killHitstopToken:
		return

	killHitstopActive = false
	killHitstopScale = 1.0

	atualizar_escala_tempo()


func atualizar_escala_tempo() -> void:
	if overdoseActive:
		Engine.time_scale = OVERDOSE_WORLD_SCALE
	elif killHitstopActive:
		Engine.time_scale = killHitstopScale
	else:
		Engine.time_scale = 1.0


func addExtraLife() -> bool:
	if lives >= MAX_LIVES:
		return false

	lives += 1
	updateUi()
	return true


func processDash(inputData, delta: float):
	if meleeing:
		return

	if inputData.dash and dashCooldown <= 0 and stamina >= DASH_STAMINA_COST:

		if not is_on_floor():

			if airDashUsed:
				return

			airDashUsed = true

		# DASH SEMPRE VAI PARA A DIREÇÃO QUE O PLAYER ESTÁ OLHANDO
		dashDir = facingDir

		dashTime = DASH_TIME
		dashCooldown = DASH_COOLDOWN
		stamina -= DASH_STAMINA_COST

		if is_on_floor():
			invencivel = true
		else:
			invencivel = false

		velocity.y = 0

		collision.disabled = true

		anim.play("dash")

		$sfx/dash.play()

		$sfx/land.volume_db = -90

		await get_tree().create_timer(0.46, true, false, true).timeout

		$sfx/land.volume_db = 2

	if dashTime > 0:

		var targetRotation = 15 * dashDir

		sprite.rotation_degrees = move_toward(
			sprite.rotation_degrees,
			targetRotation,
			1200 * delta
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
			900 * delta
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
	if meleeing or dashTime > 0 or damageKnockbackTimer > 0:
		return

	if knockback.length() > 5:
		return

	var direction = inputData.direction

	if abs(direction) < INPUT_DEADZONE:
		direction = 0.0

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


func processJump(_inputData):
	# WALL JUMP
	if (
		jumpBufferTimer > 0
		and !is_on_floor()
		and is_on_wall_custom()
		and !wallJumpLocked
		and stamina >= WALL_JUMP_STAMINA_COST
	):
		velocity.y = WALL_JUMP_FORCE_Y

		if $paredeEsq.is_colliding():
			velocity.x = WALL_JUMP_FORCE_X
			facingDir = 1
		else:
			velocity.x = -WALL_JUMP_FORCE_X
			facingDir = -1

		stamina -= WALL_JUMP_STAMINA_COST

		wallJumpLocked = true
		pulos = 1
		jumpBufferTimer = 0

		$sfx/walljump.play()
		return

	# Bloqueia pulo durante ataque/dash
	if meleeing or dashTime > 0:
		return

	if jumpBufferTimer <= 0:
		return

	# PRIMEIRO PULO
	if pulos == 0 and coyoteTimer > 0:
		pulos = 1
		coyoteTimer = 0
		jumpBufferTimer = 0

		$sfx/jump.play()
		velocity.y = JUMP_VELOCITY
		return

	# SEGUNDO PULO
	if pulos == 1:
		pulos = 2
		jumpBufferTimer = 0

		$sfx/jump2.play()
		velocity.y = JUMP_VELOCITY * 0.7


func applyKnockback(delta):
	if dashTime > 0:
		knockback = Vector2.ZERO
		return

	velocity += knockback
	knockback = knockback.move_toward(
		Vector2.ZERO,
		KNOCKBACK_DECAY * delta
	)


func processShoot(inputData):
	if runShootExitTimer > 0:
		return

	if meleeing or dashTime > 0:
		return

	if ammo <= 0:
		if inputData.shootJust:
			shoot()
		return

	if not inputData.shootJust:
		return

	# No ar: pode atirar em movimento, mas para horizontalmente.
	if not is_on_floor():
		changeState("shoot")
		return

	# No chão
	if abs(inputData.direction) > INPUT_DEADZONE:
		changeState("runShoot")
	else:
		changeState("shoot")


func takeDamage(source_position: Vector2 = Vector2.ZERO):
	if lives <= 0 or invencivel or damageInvulnerabilityTimer > 0.0:
		return

	var tinhaVidaExtra: bool = lives > 1
	lives -= 1

	if tinhaVidaExtra:
		var hitSound = $sfx/hit

		if hitSound != null:
			hitSound.pitch_scale = randf_range(0.8, 1.2)
			hitSound.play()
			$sangue.emitting = true

	updateUi()

	camera.shake(0.2, 4)
	Input.start_joy_vibration(0, 0.4, 0.7, 0.18)

	if lives <= 0:
		if overdoseActive:
			encerrar_overdose()

		get_parent().gameover()
		return

	var origem := source_position

	if origem == Vector2.ZERO:
		var inimigoMaisProximo: Node2D = null
		var menorDistancia := INF

		for inimigo in get_tree().get_nodes_in_group("inimigo"):
			if not is_instance_valid(inimigo) or not (inimigo is Node2D):
				continue

			if inimigo.get("dead") == true:
				continue

			var candidato := inimigo as Node2D
			var distancia := global_position.distance_squared_to(
				candidato.global_position
			)

			if distancia < menorDistancia:
				menorDistancia = distancia
				inimigoMaisProximo = candidato

		if is_instance_valid(inimigoMaisProximo):
			origem = inimigoMaisProximo.global_position

	var direction := -float(facingDir)

	if origem != Vector2.ZERO:
		var distanciaX := global_position.x - origem.x

		if absf(distanciaX) > 2.0:
			direction = signf(distanciaX)

	dashTime = 0.0
	collision.set_deferred("disabled", false)

	velocity.x = direction * DAMAGE_KNOCKBACK_SPEED
	velocity.y = minf(velocity.y, DAMAGE_KNOCKBACK_UP)

	knockback = Vector2.ZERO
	damageKnockbackTimer = DAMAGE_MOVEMENT_LOCK

	invencivel = true
	damageInvulnerabilityTimer = DAMAGE_INVINCIBILITY_TIME

	damageBlinkTimer = 0.0
	damageBlinkState = false

	sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)

func shoot():
	if ammo <= 0:
		if not $sfx/unloaded.is_playing():
			$sfx/unloaded.play()
		return

	ammo -= 1
	$sfx/shoot.play()
	updateUi()
	Input.start_joy_vibration(0, 0.5, 1.0, 0.185)

	var bullet = bulletScene.instantiate()

	get_tree().current_scene.add_child(bullet)

	bullet.global_position = bulletSpawner.global_position
	bullet.direction = Vector2(facingDir, 0)

	if not is_on_floor():
		airShootStop = 0.12
		velocity.y = 0

		if abs(velocity.x) > AIR_SHOOT_MAX_DRIFT:
			velocity.x *= AIR_SHOOT_BRAKE
		else:
			velocity.x = AIR_SHOOT_STOP

		anim.play("tiroPulo")

	playVoiceLine()

	$ganchoCamera/Camera2D.shake(0.3, 3)

	if $"../ui/municao/AnimationPlayer".is_playing():
		$"../ui/municao/AnimationPlayer".seek(0.25, true)
	else:
		$"../ui/municao/AnimationPlayer".play("in")


func updateAnimation(inputData):
	sprite.flip_h = facingDir < 0
	mira.scale.x = -1 if facingDir < 0 else 1

	$areaSoco/CollisionShape2D.position.x = abs(baseSocoPos.x) * facingDir
	$areaSoco/CollisionShape2D.position.y = baseSocoPos.y

	if dashTime > 0:
		changeState("dash")
		return

	if meleeing:
		return

	const DEADZONE := 0.4
	var isRunning = abs(inputData.direction) >= DEADZONE and is_on_floor()
	var isShooting = inputData.shootPressed and ammo > 0

	if currentState == "runShoot" and wasShooting and not isShooting:
		runShootExitTimer = RUN_SHOOT_EXIT_DELAY

	if currentState == "runShoot" and runShootExitTimer > 0:
		wasShooting = isShooting
		return

	wasShooting = isShooting

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
		$sfx/walk/AnimationPlayer.play("idle")
	else:
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

	var fadeDuration := 0.22

	if overdoseActive:
		ghost.modulate = Color(
			0.65,
			0.25,
			1.0,
			OVERDOSE_GHOST_OPACITY
		)

		fadeDuration = OVERDOSE_GHOST_FADE
	else:
		ghost.modulate = Color(1, 1, 1, 0.6)

	get_parent().add_child(ghost)

	var tween := create_tween()

	if overdoseActive:
		tween.set_ignore_time_scale(true)

	tween.tween_property(
		ghost,
		"modulate:a",
		0.0,
		fadeDuration
	)

	tween.finished.connect(ghost.queue_free)

func aumentarToxicidade(valor):
	toxicidade = minf(toxicidade + valor, TOXICIDADE_MAXIMA)
	atualizarToxicidadeVisual()

	if toxicidade >= TOXICIDADE_MAXIMA:
		get_parent().gameover()


func definirAreaToxica(estado):
		dentroAreaToxica = estado

func atualizarToxicidadeVisual():
	var intensidade := clampf(toxicidade / TOXICIDADE_MAXIMA, 0.0, 1.0)

	modulate = Color.WHITE.lerp(Color.GREEN, intensidade)

	if is_instance_valid(toxicOverlay):
		toxicOverlay.color = Color(0.0, 0.85, 0.05, intensidade * 0.10)

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
			ammoIcons[i].modulate = Color.WHITE
		else:
			ammoIcons[i].modulate = Color(0.3, 0.3, 0.3, 0.5)

	if livesUI == null:
		return

	if lives == 1:
		livesUI.get_node_or_null("items/siringasVermelhas").hide()

	if lives == 2:
		livesUI.get_node_or_null("items/siringasVermelhas").show()


func _on_area_soco_body_entered(body):

	var inimigo: Node = body
	var direcao_ataque: float = 1 if not $Sprite2D.flip_h else -1

	while inimigo:

		if inimigo.has_method("rebater"):
			inimigo.rebater(self)
			return

		if inimigo.get("imune_melee") == true:
			return

		if inimigo.has_method("morrer_melee"):
			inimigo.morrer_melee(direcao_ataque)
			return

		if inimigo.has_method("morrer"):
			inimigo.morrer()
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
	if overdoseActive:
		encerrar_overdose()

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


func ativar_inimigos_proximos():

	for inimigo in get_tree().get_nodes_in_group("inimigo"):

		if not is_instance_valid(inimigo):
			continue

		if inimigo.dead:
			continue

		if inimigo.process_mode != Node.PROCESS_MODE_DISABLED:
			continue

		var distancia := global_position.distance_to(
			inimigo.global_position
		)

		if distancia <= inimigo.DISTANCIA_ATIVACAO:
			inimigo.ativar()
