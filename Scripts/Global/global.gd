extends Node

var freshStart = true
var volume := 100
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

const CAMINHO = "user://sickoutSave.txt"
const CONFIG = "user://config.cfg"
const RANKS = "user://ranks.cfg"

func _ready():
	carregar_config()
	carregar_ranks()

	RenderingServer.set_default_clear_color(Color.BLACK)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


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
	cfg.set_value("geral", "lingua", lingua)

	for id in fitas.keys():
		cfg.set_value("fitas", id, fitas[id])

	cfg.save(CONFIG)

func carregar_config():
	var cfg = ConfigFile.new()

	if cfg.load(CONFIG) != OK:
		return

	volume = cfg.get_value("geral", "volume", 100)
	lingua = cfg.get_value("geral", "lingua", null)

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


func _process(_delta: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Master")

	AudioServer.set_bus_volume_db(
		bus_idx,
		linear_to_db(volume / 100.0)
	)
