extends Node

enum Tipo {
	IMAGEM,
	TEXTO,
	ITEM
}

@export var tipo : Tipo

@export var item_nome : String
@export var textura : Texture2D
@export_multiline var texto : String

var player_na_area = null
var player_interagindo = null
var painel_aberto = false


func _ready() -> void:
	$ui/imagemPainel.hide()
	$ui/textoPainel.hide()


func _process(_delta):
	if Input.is_action_just_pressed("interact") and player_na_area and !painel_aberto:
		match tipo:
			Tipo.IMAGEM:
				$ui/imagemPainel/TextureRect.texture = textura
				$ui/imagemPainel.show()
				$ui/imagemPainel/fechar.grab_focus()

				player_interagindo = player_na_area
				player_interagindo.freezePlayer()
				painel_aberto = true

			Tipo.TEXTO:
				$ui/textoPainel/info.text = "[shake]" + texto
				$ui/textoPainel.show()
				$ui/textoPainel/fechar.grab_focus()

				player_interagindo = player_na_area
				player_interagindo.freezePlayer()
				painel_aberto = true

			Tipo.ITEM:
				pass
