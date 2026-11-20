
extends Node

var freshStart = true
var volume := 100
var volume_musica: float = 100.0
var volume_sons: float = 100.0
var spawnAtual: Node2D

var timerTempo: float = 0.0
var respawn = false
var speedrun = false

var pontuacaoAtual := 0
var killsAtual := 0
var tempoAtual := 0.0
var mortesAtual := 0
var tempoTotal = 0

var nomeFaseAtual := "Desconhecida"

signal documento_solicitado(documento: DocumentoLore)

var animacao = false
var playerAtual = ""

var checkpointPos := Vector2.ZERO
var proxFase

var metaPontuacao
var metaKills
var metaTempo

var ranks := {}
var rankAtual := ""

var itens := {}
var fitas := {}

var lingua = null

var potatoMode = false

const CAMINHO = "user://sickoutSave.txt"
const CONFIG = "user://config.cfg"
const RANKS = "user://ranks.cfg"

const BUS_MUSICA := "Music"
const BUS_SONS := "Sons"


func _ready() -> void:
	configurar_barramentos_audio()

	carregar_config()
	carregar_ranks()

	aplicar_volumes_audio()

	var callback := Callable(self, "_on_audio_node_added")

	if not get_tree().node_added.is_connected(callback):
		get_tree().node_added.connect(callback)

	var cena = get_tree().current_scene

	if is_instance_valid(cena):
		configurar_audio_recursivo(cena)

	RenderingServer.set_default_clear_color(Color.BLACK)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func configurar_barramentos_audio() -> void:
	garantir_barramento(BUS_MUSICA)
	garantir_barramento(BUS_SONS)


func garantir_barramento(nome: String) -> int:
	var indice := AudioServer.get_bus_index(nome)

	if indice == -1:
		AudioServer.add_bus()
		indice = AudioServer.bus_count - 1
		AudioServer.set_bus_name(indice, nome)

	AudioServer.set_bus_send(indice, "Master")

	return indice


func eh_player_audio(node: Node) -> bool:
	return (
		node is AudioStreamPlayer
		or node is AudioStreamPlayer2D
		or node is AudioStreamPlayer3D
	)


func configurar_audio_node(node: Node) -> void:
	if not eh_player_audio(node):
		return

	var nome := String(node.name).to_lower()

	if node.is_in_group("musica") or nome in ["music", "musica", "bgm", "trilha"]:
		node.bus = BUS_MUSICA
	elif node.bus == "Master" or AudioServer.get_bus_index(node.bus) == -1:
		node.bus = BUS_SONS


func configurar_audio_recursivo(node: Node) -> void:
	configurar_audio_node(node)

	for filho in node.get_children():
		configurar_audio_recursivo(filho)


func _on_audio_node_added(node: Node) -> void:
	configurar_audio_node(node)


func definir_volume_musica(valor: float) -> void:
	volume_musica = clampf(valor, 0.0, 100.0)
	aplicar_volume_barramento(BUS_MUSICA, volume_musica)


func definir_volume_sons(valor: float) -> void:
	volume_sons = clampf(valor, 0.0, 100.0)
	aplicar_volume_barramento(BUS_SONS, volume_sons)


func aplicar_volumes_audio() -> void:
	aplicar_volume_barramento(BUS_MUSICA, volume_musica)
	aplicar_volume_barramento(BUS_SONS, volume_sons)


func aplicar_volume_barramento(nome: String, valor: float) -> void:
	var indice := AudioServer.get_bus_index(nome)

	if indice == -1:
		return

	var volume_normalizado := clampf(valor, 0.0, 100.0)

	var volume_db := -80.0

	if volume_normalizado > 0.0:
		volume_db = linear_to_db(volume_normalizado / 100.0)

	AudioServer.set_bus_volume_db(indice, volume_db)
	AudioServer.set_bus_mute(indice, volume_normalizado <= 0.0)


func formatar_tempo(tempo: float):
	var minutos = int(tempo / 60)
	var segundos = int(tempo) % 60
	var milissegundos = int((tempo - floor(tempo)) * 1000)

	return "%02dm%02ds%03d" % [
		minutos,
		segundos,
		milissegundos
	]


func salvar_config():
	var cfg = ConfigFile.new()

	cfg.set_value("geral", "volume", volume)
	cfg.set_value("geral", "volume_musica", volume_musica)
	cfg.set_value("geral", "volume_sons", volume_sons)
	cfg.set_value("geral", "lingua", lingua)
	cfg.set_value("geral", "potatoMode", potatoMode)

	for id in fitas.keys():
		cfg.set_value("fitas", id, fitas[id])

	cfg.save(CONFIG)


func carregar_config():
	var cfg = ConfigFile.new()

	if cfg.load(CONFIG) != OK:
		return

	volume = int(cfg.get_value("geral", "volume", 100))

	volume_musica = clampf(
		float(cfg.get_value("geral", "volume_musica", volume)),
		0.0,
		100.0
	)

	volume_sons = clampf(
		float(cfg.get_value("geral", "volume_sons", volume)),
		0.0,
		100.0
	)

	lingua = cfg.get_value("geral", "lingua", null)
	potatoMode = cfg.get_value("geral", "potatoMode", false)

	fitas.clear()

	if cfg.has_section("fitas"):
		for id in cfg.get_section_keys("fitas"):
			fitas[id] = cfg.get_value("fitas", id, false)


func salvar_rank_fase():
	if nomeFaseAtual == "":
		return

	var ordem = {
		"D": 0,
		"C": 1,
		"B": 2,
		"A": 3,
		"S": 4
	}

	var rank_antigo = ranks.get(nomeFaseAtual, "")

	if rank_antigo == "" or ordem[rankAtual] > ordem[rank_antigo]:
		ranks[nomeFaseAtual] = rankAtual
		salvar_ranks()


func salvar_ranks():
	var cfg = ConfigFile.new()

	for fase in ranks.keys():
		cfg.set_value("ranks", fase, ranks[fase])

	cfg.save(RANKS)


func carregar_ranks():
	var cfg = ConfigFile.new()

	if cfg.load(RANKS) != OK:
		return

	ranks.clear()

	var fases = cfg.get_section_keys("ranks")

	for fase in fases:
		ranks[fase] = cfg.get_value("ranks", fase, "")


func salvar_player(id_player: String, nome: String, tempo: float):
	var banco = carregar_banco()

	banco[id_player] = {
		"nome": nome,
		"tempo": tempo
	}

	var arquivo = FileAccess.open(CAMINHO, FileAccess.WRITE)

	for id in banco.keys():
		var p = banco[id]
		var linha = id + "|" + p["nome"] + "|" + str(p["tempo"])
		arquivo.store_line(linha)

	arquivo.close()


func carregar_banco():
	var banco = {}

	if not FileAccess.file_exists(CAMINHO):
		return banco

	var arquivo = FileAccess.open(CAMINHO, FileAccess.READ)

	while not arquivo.eof_reached():
		var linha = arquivo.get_line()

		if linha == "":
			continue

		var partes = linha.split("|")

		if partes.size() >= 3:
			banco[partes[0]] = {
				"nome": partes[1],
				"tempo": float(partes[2])
			}

	arquivo.close()

	return banco


func criar_player(nome: String):
	var banco = carregar_banco()

	var numero = banco.size() + 1
	var id_player = "player" + str(numero)

	playerAtual = id_player

	salvar_player(id_player, nome, 0.0)

	return id_player


func salvar_tempo_atual(novo_tempo: float):
	if playerAtual == "":
		return

	var banco = carregar_banco()

	if banco.has(playerAtual):
		banco[playerAtual]["tempo"] = novo_tempo

		var arquivo = FileAccess.open(CAMINHO, FileAccess.WRITE)

		for id in banco.keys():
			var p = banco[id]
			var linha = id + "|" + p["nome"] + "|" + str(p["tempo"])
			arquivo.store_line(linha)

		arquivo.close()


func pegar_player(id_player: String):
	var banco = carregar_banco()

	if banco.has(id_player):
		return banco[id_player]

	return null


func pegar_leaderboard():
	var banco = carregar_banco()

	var lista = []

	for id in banco.keys():
		var player = banco[id]

		lista.append({
			"nome": player["nome"],
			"tempo": player["tempo"],
			"tempoFormatado": formatar_tempo(player["tempo"])
		})

	lista.sort_custom(func(a, b):
		return a["tempo"] < b["tempo"]
	)

	return lista


func apagar_saves() -> void:
	var caminhos: Array[String] = [CAMINHO, CONFIG, RANKS]

	for caminho in caminhos:
		if FileAccess.file_exists(caminho):
			var erro := DirAccess.remove_absolute(ProjectSettings.globalize_path(caminho))

			if erro != OK:
				push_error("Falha ao apagar " + caminho + ": " + str(erro))
				return

	volume = 100
	volume_musica = 100.0
	volume_sons = 100.0

	lingua = null
	potatoMode = false

	aplicar_volumes_audio()

	ranks.clear()
	fitas.clear()
	itens.clear()

	playerAtual = ""
	checkpointPos = Vector2.ZERO
	spawnAtual = null

	freshStart = true
	respawn = false
	speedrun = false

	pontuacaoAtual = 0
	killsAtual = 0
	tempoAtual = 0.0
	mortesAtual = 0
	tempoTotal = 0
	timerTempo = 0.0
