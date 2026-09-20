extends Node

const VERSAO := "14.06.26"
const TEMPO_ENTRE_AUTOSAVES := 30.0
const FPS_MINIMO_VALIDO := 20
const FRAMES_IGNORADOS := 120

var fps_min := INF
var fps_max := 0
var fps_soma := 0.0
var frames := 0

var slow_frames := 0

var maior_delta := 0.0
var fase_maior_travada := "Nenhuma"

var tempo_jogo := 0.0
var tempo_desde_autosave := 0.0

var maiores_travadas = []

var fases_visitadas = []


func _ready():

	if not fases_visitadas.has("menu"):
		fases_visitadas.append("menu")


func _process(delta):

	tempo_jogo += delta
	tempo_desde_autosave += delta

	var fps := Engine.get_frames_per_second()

	# Ignora os primeiros frames e valores absurdos
	if frames > FRAMES_IGNORADOS and fps > FPS_MINIMO_VALIDO:
		fps_min = min(fps_min, fps)

	fps_max = max(fps_max, fps)

	fps_soma += fps
	frames += 1

	# Frame acima de 50 ms
	if frames > FRAMES_IGNORADOS and delta > 0.05:

		slow_frames += 1

		var fase := "Desconhecida"

		if Global.nomeFaseAtual != null and not Global.nomeFaseAtual.is_empty():
			fase = Global.nomeFaseAtual

		maiores_travadas.append({
			"ms": round(delta * 1000.0),
			"fase": fase
		})

		maiores_travadas.sort_custom(
			func(a, b):
				return a["ms"] > b["ms"]
		)

		if maiores_travadas.size() > 5:
			maiores_travadas.resize(5)

	# Pior travada da sessão
	if delta > maior_delta:

		maior_delta = delta

		if Global.nomeFaseAtual.is_empty():
			fase_maior_travada = "Desconhecida"
		else:
			fase_maior_travada = Global.nomeFaseAtual

	# Atualiza o relatório periodicamente
	if tempo_desde_autosave >= TEMPO_ENTRE_AUTOSAVES:

		tempo_desde_autosave = 0.0

		gerar_relatorio(false)


func _notification(what):

	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		gerar_relatorio(false)


func registrar_fase(nome):

	if nome == "":
		nome = "Desconhecida"

	Global.nomeFaseAtual = nome

	if not fases_visitadas.has(nome):
		fases_visitadas.append(nome)


func fps_medio():

	if frames == 0:
		return 0

	return int(fps_soma / frames)


func formatar_tempo(segundos):

	var h := int(segundos / 3600)
	var m := int(segundos / 60) % 60
	var s := int(segundos) % 60

	return "%02d:%02d:%02d" % [h, m, s]


func gerar_relatorio(abrir_pasta := true):

	var texto := ""

	texto += "=== SICKOUT PERFORMANCE LOG ===\n\n"

	texto += "Versao:\n"
	texto += VERSAO + "\n\n"

	texto += "Data:\n"
	texto += Time.get_datetime_string_from_system() + "\n\n"

	texto += "Engine:\n"
	texto += Engine.get_version_info()["string"] + "\n\n"

	texto += "Sistema Operacional:\n"
	texto += OS.get_name() + "\n\n"

	texto += "CPU:\n"
	texto += OS.get_processor_name() + "\n\n"

	texto += "Threads da CPU:\n"
	texto += str(OS.get_processor_count()) + "\n\n"

	texto += "GPU:\n"

	var rd = RenderingServer.get_rendering_device()

	if rd:
		texto += rd.get_device_name() + "\n\n"
	else:
		texto += "Desconhecida\n\n"

	texto += "Renderer:\n"
	texto += RenderingServer.get_current_rendering_method() + "\n\n"

	texto += "Resolucao:\n"
	texto += str(DisplayServer.window_get_size()) + "\n\n"

	texto += "Memoria RAM usada:\n"
	texto += str(round(OS.get_static_memory_usage() / 1024.0 / 1024.0)) + " MB\n\n"

	texto += "Tempo total jogado:\n"
	texto += formatar_tempo(tempo_jogo) + "\n\n"

	texto += "Frames analisados:\n"
	texto += str(frames) + "\n\n"

	texto += "FPS medio:\n"
	texto += str(fps_medio()) + "\n\n"

	texto += "FPS minimo:\n"

	if fps_min == INF:
		texto += "Nao registrado\n\n"
	else:
		texto += str(fps_min) + "\n\n"

	texto += "FPS maximo:\n"
	texto += str(fps_max) + "\n\n"

	texto += "Frames lentos (>50 ms):\n"
	texto += str(slow_frames) + "\n\n"

	texto += "Maior travada:\n"
	texto += str(round(maior_delta * 1000.0)) + " ms\n\n"

	texto += "Fase da maior travada:\n"
	texto += fase_maior_travada + "\n\n"

	texto += "Fase atual:\n"
	texto += Global.nomeFaseAtual + "\n\n"

	texto += "Cena atual:\n"

	if get_tree().current_scene:
		texto += get_tree().current_scene.name + "\n\n"
	else:
		texto += "Desconhecida\n\n"

	texto += "Pontuacao:\n"
	texto += str(Global.pontuacaoAtual) + "\n\n"

	texto += "Kills:\n"
	texto += str(Global.killsAtual) + "\n\n"

	texto += "Mortes:\n"
	texto += str(Global.mortesAtual) + "\n\n"

	texto += "Top 5 travadas:\n"

	if maiores_travadas.is_empty():

		texto += "Nenhuma\n"

	else:

		for t in maiores_travadas:
			texto += str(t["ms"]) + " ms - " + t["fase"] + "\n"

	texto += "\n"

	texto += "Fases visitadas:\n"

	for fase in fases_visitadas:
		texto += fase + "\n"

	var file := FileAccess.open(
		"user://desempenho.txt",
		FileAccess.WRITE
	)

	if file:

		file.store_string(texto)
		file.close()

		if abrir_pasta:
			OS.shell_open(ProjectSettings.globalize_path("user://"))
