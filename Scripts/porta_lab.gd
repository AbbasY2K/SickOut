extends Node2D

var player_na_entrada = null
var player_na_saida = null
var pode_teleportar = true

@onready var entrada = $entrada
@onready var saida = $saida

@onready var musica = preload("res://Audio/Musicas/Fases/lab1.mp3")
@onready var musicaOriginal = $"../../sfx/music"
@onready var streamOriginal = musicaOriginal.stream


func _process(_delta):
	if Input.is_action_just_pressed("interact") and pode_teleportar:
		if player_na_entrada:
			await teleportar(player_na_entrada, saida.global_position)
		elif player_na_saida:
			await teleportar(player_na_saida, entrada.global_position)


func teleportar(player, destino):
	var veio_da_entrada = player_na_entrada != null

	$AnimationPlayer.play("open")
	$"../../sfx/abrirPorta".play()
	$"../../ui/blackout/AnimationPlayer".play("inOut")

	pode_teleportar = false
	player.freezePlayer()
	musicaOriginal.stop()

	if veio_da_entrada:
		player.global_position = entrada.global_position

	else:
		player.global_position = saida.global_position

	player.global_position += Vector2(0, 3)

	await get_tree().create_timer(0.5).timeout
	player.global_position = destino
	player.global_position += Vector2(0, 3)
	$"../../player/ganchoCamera/Camera2D".reset_smoothing()
	
	if veio_da_entrada:
		musicaOriginal.stream = musica
		musicaOriginal.play()

	else:

		musicaOriginal.stream = streamOriginal
		musicaOriginal.play()
	
	await get_tree().create_timer(0.5).timeout
	$"../../sfx/fecharPorta".play()
	player.unfreezePlayer()
	pode_teleportar = true

func _on_entrada_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_na_entrada = body
		$"../../ui/dica".show()
		$"../../ui/dica/Label".text = "[center]PRESSIONE [img=24x24]res://Sprites/UI/botao_quadrado.png[/img]"
		if OS.has_feature("mobile"):
			$"../../ui/controlesGameplay/interagir1".show()


func _on_entrada_body_exited(body: Node2D) -> void:
	if body == player_na_entrada:
		player_na_entrada = null
		$"../../ui/dica".hide()
		if OS.has_feature("mobile"):
			$"../../ui/controlesGameplay/interagir1".hide()

func _on_saida_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_na_saida = body
		$"../../ui/dica".show()
		$"../../ui/dica/Label".text = "[center]PRESSIONE [img=24x24]res://Sprites/UI/botao_quadrado.png[/img]"
		if OS.has_feature("mobile"):
			$"../../ui/controlesGameplay/interagir1".show()


func _on_saida_body_exited(body: Node2D) -> void:
	if body == player_na_saida:
		player_na_saida = null
		$"../../ui/dica".hide()
		if OS.has_feature("mobile"):
			$"../../ui/controlesGameplay/interagir1".hide()
