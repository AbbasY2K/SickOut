extends Node2D

var tempo := 0.0

@onready var texto = $HBoxContainer/texto2

func _ready() -> void:
	Global.timerTempo = 0.0
	tempo = 0.0

func _process(delta: float) -> void:
	tempo += delta

	var minutos = int(tempo / 60)
	var segundos = int(tempo) % 60

	texto.text = "%02d:%02d" % [minutos, segundos]

	# Wave constante
	var wave = 1.0 + sin(Time.get_ticks_msec() * 0.005) * 0.03
	texto.scale = Vector2(wave, wave)

	Global.timerTempo = tempo
	Global.tempoTotal += delta
