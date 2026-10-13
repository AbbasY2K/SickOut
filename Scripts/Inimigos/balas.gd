extends Inimigo

@export var cena_bala: PackedScene
@export var intervalo_disparo := 0.9
@export var velocidade_mira := 8.0
@export var exigir_linha_de_visao := true
@export var distancia_spawn := 12.0
@export var tempo_fade_morte := 0.4
@export var tempo_antes_de_sumir := 0.2

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var mira: RayCast2D = $Sprite2D/mira
@onready var bala_spawning: Node2D = $Sprite2D/mira/balaSpawner

var tempo_disparo := 0.0
var escala_original: Vector2
var tween_disparo: Tween


func _ready() -> void:
	super._ready()

	escala_original = sprite.scale

	ativar()

	mira.enabled = true
	mira.add_exception(self)
	mira.rotation = PI / 2.0

	area.body_entered.connect(_on_area_2d_body_entered)
	area.body_exited.connect(_on_area_2d_body_exited)

	tempo_disparo = intervalo_disparo


func _physics_process(delta: float) -> void:
	if dead:
		return

	if not is_instance_valid(player):
		return

	var direcao: Vector2 = global_position.direction_to(
		player.global_position
	)

	var angulo_alvo: float = direcao.angle()

	sprite.global_rotation = lerp_angle(
		sprite.global_rotation,
		angulo_alvo - PI / 2.0,
		velocidade_mira * delta
	)

	mira.target_position = mira.to_local(player.global_position)
	mira.force_raycast_update()

	tempo_disparo -= delta

	if tempo_disparo <= 0.0:
		if _pode_disparar():
			_disparar()

		tempo_disparo = intervalo_disparo


func _pode_disparar() -> bool:
	if not exigir_linha_de_visao:
		return true

	if not mira.is_colliding():
		return false

	var alvo: Object = mira.get_collider()

	return alvo == player


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		tempo_disparo = 0.15


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		tempo_disparo = 0.0


func _disparar() -> void:
	if cena_bala == null:
		return

	if not is_instance_valid(player):
		return

	var direcao: Vector2 = bala_spawning.global_position.direction_to(
		player.global_position
	)

	var bala: CharacterBody2D = cena_bala.instantiate()

	bala.direcao = direcao
	bala.maquina = self

	bala.global_position = bala_spawning.global_position + (
		direcao * distancia_spawn
	)

	get_tree().current_scene.add_child(bala)

	bala.add_collision_exception_with(self)

	$atirar.play()

	_animar_disparo()


func _animar_disparo() -> void:
	if tween_disparo != null and tween_disparo.is_running():
		tween_disparo.kill()

	sprite.scale = escala_original

	tween_disparo = create_tween()

	tween_disparo.tween_property(
		sprite,
		"scale",
		escala_original * Vector2(1.15, 0.85),
		0.05
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween_disparo.tween_property(
		sprite,
		"scale",
		escala_original,
		0.09
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func morrer_tiro(_dir_ataque := 1.0) -> void:
	_morrer_maquina()


func morrer() -> void:
	_morrer_maquina()


func _morrer_maquina() -> void:
	if dead:
		return

	dead = true
	pausar_fisica = true
	player = null
	tempo_disparo = 999999.0

	desativar_colisoes_morte()

	if tween_disparo != null and tween_disparo.is_running():
		tween_disparo.kill()

	sprite.scale = escala_original

	$explosao.play()

	if has_node("sangue"):
		$sangue.emitting = true

		if $sangue.one_shot:
			await $sangue.finished

	if has_node("desligar"):
		$desligar.play()

	var modulate_final: Color = sprite.modulate
	modulate_final.a = 0.0

	var tween: Tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		sprite,
		"modulate",
		modulate_final,
		tempo_fade_morte
	)

	tween.tween_property(
		sprite,
		"scale",
		escala_original * 0.65,
		tempo_fade_morte
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	tween.tween_property(
		sprite,
		"rotation",
		sprite.rotation + deg_to_rad(25.0),
		tempo_fade_morte
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await tween.finished

	registrar_kill(SCORE_MORTE)

	await get_tree().create_timer(tempo_antes_de_sumir).timeout

	queue_free()
