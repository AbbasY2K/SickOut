
extends CanvasLayer

@onready var titulo: Label = $documento/elementos/titulo
@onready var texto: RichTextLabel = $documento/elementos/texto
@onready var animacao: AnimationPlayer = $AnimationPlayer
@onready var botao_voltar: Button = $voltar

const DOCUMENTO_TESTE: DocumentoLore = preload("res://Cenas/Cutscenes/Documentos/documento_placeholder.tres")

@export var shader_distorcao: CanvasLayer
@export var musica: AudioStreamPlayer
@export_range(-40.0, -10.0, 1.0) var volume_documento_db := -28.0

var documento_aberto := false
var fechando := false
var pausa_anterior := false

var distorcao_visivel_anterior := true
var volume_musica_anterior := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	botao_voltar.pressed.connect(fechar_documento)
	Global.documento_solicitado.emit(DOCUMENTO_TESTE)


func abrir_documento(documento: DocumentoLore) -> void:
	if documento == null or documento_aberto:
		return

	documento_aberto = true
	pausa_anterior = get_tree().paused

	titulo.text = documento.titulo
	texto.text = documento.texto

	if is_instance_valid(shader_distorcao):
		distorcao_visivel_anterior = shader_distorcao.visible
		shader_distorcao.visible = false

	if is_instance_valid(musica):
		if is_equal_approx(musica.volume_db, volume_documento_db):
			musica.volume_db = volume_musica_anterior

	visible = true
	get_tree().paused = true
	
	var hud: Node = get_tree().get_first_node_in_group("hud")

	if is_instance_valid(hud) and hud.has_method("parar_distorcao_vhs"):
		hud.parar_distorcao_vhs()

	animacao.play("in")


func fechar_documento() -> void:
	if not documento_aberto or fechando:
		return

	fechando = true
	animacao.play_backwards("in")

	await animacao.animation_finished

	visible = false
	documento_aberto = false
	fechando = false

	if is_instance_valid(shader_distorcao):
		shader_distorcao.visible = distorcao_visivel_anterior

	if is_instance_valid(musica):
		musica.volume_db = volume_musica_anterior

	get_tree().paused = pausa_anterior
