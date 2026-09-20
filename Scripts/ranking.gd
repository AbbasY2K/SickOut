extends Node2D

@onready var camera = $Camera2D

var tempo := 0.0
var offset_base := Vector2.ZERO

func _ready():
	if camera:
		offset_base = camera.position

	$shader.show()

	var pontos = Global.pontuacaoAtual if Global.pontuacaoAtual != null else 0
	var kills = Global.killsAtual if Global.killsAtual != null else 0
	var mortes = Global.mortesAtual if Global.mortesAtual != null else 0
	var tempo_total = Global.tempoTotal if Global.tempoTotal != null else 0.0
	
	$ui/labels/pontos.text = "[tornado radius=1 freq=3]%s:[/tornado] [shake level=2]%d[/shake]" % [
		Tradutor.get_text("PONTOS"),
		pontos
	]

	$ui/labels/kills.text = "[tornado radius=1 freq=3]%s:[/tornado] [shake level=2]%d[/shake]" % [
		Tradutor.get_text("KILLS"),
		kills
	]

	$ui/labels/mortes.text = "[tornado radius=1 freq=3]%s:[/tornado] [shake level=2]%d[/shake]" % [
		Tradutor.get_text("MORTES"),
		mortes
	]

	var minutos = int(tempo_total / 60)
	var segundos = int(tempo_total) % 60

	$ui/labels/tempo.text = "[tornado radius=1 freq=3]%s:[/tornado] [shake level=2]%02d:%02d[/shake]" % [
		Tradutor.get_text("TEMPO"),
		minutos,
		segundos
	]
	
	calcular_rank()
	
	await get_tree().create_timer(10.3).timeout
	$ambiente.play()

func _input(event):
	if event.is_action_pressed("interact"):
		var anim = $ui/AnimationPlayer

		if anim.current_animation == "in" and anim.is_playing():
			anim.seek(10.25, true)

func _process(delta):
	if camera == null:
		return

	tempo += delta

	var x = sin(tempo * 17.0) * 0.25
	var y = sin(tempo * 23.0) * 0.35

	y += sin(tempo * 2.3) * 0.4

	var ciclo = fmod(tempo, 1.7)

	if ciclo < 0.08:
		y += 1.6 * (1.0 - ciclo / 0.08)
	elif ciclo < 0.13:
		y -= 0.8 * (1.0 - (ciclo - 0.08) / 0.05)

	camera.position = offset_base + Vector2(x, y)


func calcular_rank():

	var score := 0.0

	var pontos = Global.pontuacaoAtual if Global.pontuacaoAtual != null else 0.0
	var meta_pontos = Global.metaPontuacao if Global.metaPontuacao != null else 1.0

	var kills = Global.killsAtual if Global.killsAtual != null else 0
	var meta_kills = Global.metaKills if Global.metaKills != null else 1.0

	var mortes = Global.mortesAtual if Global.mortesAtual != null else 0

	var tempo_total = Global.tempoTotal if Global.tempoTotal != null else 0.0
	var meta_tempo = Global.metaTempo if Global.metaTempo != null else 0.0

	meta_pontos = max(meta_pontos, 1.0)
	meta_kills = max(meta_kills, 1.0)

	score += min(
		pontos / meta_pontos * 40.0,
		40.0
	)

	score += min(
		float(kills) / meta_kills * 25.0,
		25.0
	)

	score += max(
		20.0 - mortes * 4.0,
		0.0
	)

	score += max(
		15.0 - (tempo_total - meta_tempo) / 10.0,
		0.0
	)

	var rank := ""

	if score >= 95:
		rank = "S"
		$ui/rank.text = "RANK: [color=gold][wave amp=25 freq=4]S[/wave][/color]"

	elif score >= 80:
		rank = "A"
		$ui/rank.text = "RANK: [color=lime_green]A[/color]"

	elif score >= 60:
		rank = "B"
		$ui/rank.text = "RANK: [color=deepskyblue]B[/color]"

	elif score >= 40:
		rank = "C"
		$ui/rank.text = "RANK: [color=orange]C[/color]"

	else:
		rank = "D"
		$ui/rank.text = "RANK: [color=red]D[/color]"

	Global.rankAtual = rank
	Global.salvar_rank_fase()

func _on_continuar_pressed() -> void:
	$ui/AnimationPlayer.play("out")

	Global.mortesAtual = 0
	Global.tempoTotal = 0

	await get_tree().create_timer(0.5).timeout

	if Global.proxFase != null:
		get_tree().change_scene_to_packed(Global.proxFase)
	else:
		push_error("Global.proxFase é nulo.")


func _on_niveis_pressed() -> void:
	$ui/AnimationPlayer.play("out")

	Global.mortesAtual = 0
	Global.tempoTotal = 0

	await get_tree().create_timer(0.5).timeout

	get_tree().change_scene_to_file("res://Cenas/Menus/fases.tscn")
