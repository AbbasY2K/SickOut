extends Node2D

@export var item_necessario: String

var player_na_entrada = null
var player_na_saida = null
var pode_teleportar = true
var destrancado = false

@onready var entrada = $entrada
@onready var saida = $saida

var tentando_abrir = false

func _process(_delta):
	if Input.is_action_just_pressed("interact") and pode_teleportar:

		if player_na_entrada:
			if destrancado:
				await teleportar(player_na_entrada, saida.global_position)

			elif Global.itens.has(item_necessario):
				Global.itens.erase(item_necessario)
				destrancado = true
				$AnimationPlayer.play("open")
				await teleportar(player_na_entrada, saida.global_position)

			else:
				tentar_abrir_sem_chave($entrada/portaEntrada)

		elif player_na_saida:
			if destrancado:
				await teleportar(player_na_saida, entrada.global_position)

			elif Global.itens.has(item_necessario):
				Global.itens.erase(item_necessario)
				destrancado = true
				$AnimationPlayer.play("open")
				await teleportar(player_na_saida, entrada.global_position)

			else:
				tentar_abrir_sem_chave($saida/portaSaida)


func teleportar(player, destino):
	var veio_da_entrada = player_na_entrada != null

	$"../../../sfx/abrirPorta".play()
	$"../../../ui/blackout/AnimationPlayer".play("inOut")

	pode_teleportar = false
	player.freezePlayer()

	if veio_da_entrada:
		player.global_position = entrada.global_position
	else:
		player.global_position = saida.global_position

	player.global_position += Vector2(0, 3)

	await get_tree().create_timer(0.5).timeout

	player.global_position = destino
	player.global_position += Vector2(0, 3)

	# Salva a posição final do jogador como checkpoint
	Global.checkpointPos = player.global_position

	$"../../../player/ganchoCamera/Camera2D".reset_smoothing()

	await get_tree().create_timer(0.5).timeout

	$"../../../sfx/fecharPorta".play()

	player.unfreezePlayer()
	pode_teleportar = true


func _on_entrada_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_na_entrada = body
		$"../../../ui/dica".show()

		if destrancado or Global.itens.has(item_necessario):
			$"../../../ui/dica/Label".text = Tradutor.get_text("PRESS_QUADRADO")
		else:
			$"../../../ui/dica/Label".text = Tradutor.get_text("TRANCADO")

		if OS.has_feature("mobile"):
			$"../../../ui/controlesGameplay/interagir1".show()


func _on_entrada_body_exited(body: Node2D) -> void:
	if body == player_na_entrada:
		player_na_entrada = null
		$"../../../ui/dica".hide()

		if OS.has_feature("mobile"):
			$"../../../ui/controlesGameplay/interagir1".hide()


func _on_saida_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_na_saida = body
		$"../../../ui/dica".show()

		if destrancado or Global.itens.has(item_necessario):
			$"../../../ui/dica/Label".text = Tradutor.get_text("PRESS_QUADRADO")
		else:
			$"../../../ui/dica/Label".text = Tradutor.get_text("TRANCADO")

		if OS.has_feature("mobile"):
			$"../../../ui/controlesGameplay/interagir1".show()


func _on_saida_body_exited(body: Node2D) -> void:
	if body == player_na_saida:
		player_na_saida = null
		$"../../../ui/dica".hide()

		if OS.has_feature("mobile"):
			$"../../../ui/controlesGameplay/interagir1".hide()

func tentar_abrir_sem_chave(porta: Node2D):
	if tentando_abrir:
		return

	tentando_abrir = true
	$nope.play()

	var posicao_original = porta.position

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		porta,
		"position:x",
		posicao_original.x + 3,
		0.05
	)

	tween.tween_property(
		porta,
		"position:x",
		posicao_original.x - 3,
		0.07
	)

	tween.tween_property(
		porta,
		"position:x",
		posicao_original.x + 2,
		0.05
	)

	tween.tween_property(
		porta,
		"position:x",
		posicao_original.x,
		0.05
	)

	await tween.finished

	tentando_abrir = false
