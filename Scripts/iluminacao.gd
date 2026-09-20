extends Node2D

@export var chance_de_flicker := 0.8

var luzes_com_flicker = []
var timers = {}
var piscadas_restantes = {}

func _ready():
	randomize()

	for child in get_children():
		var nome = child.name.to_lower()

		if nome.begins_with("luz"):
			var sufixo = nome.substr(3)

			if sufixo.is_valid_int():
				if randf() < chance_de_flicker:
					luzes_com_flicker.append(child)
					timers[child] = randf_range(1.0, 4.0)
					piscadas_restantes[child] = 0

func _process(delta):
	for luz in luzes_com_flicker:
		if !is_instance_valid(luz):
			continue

		timers[luz] -= delta

		if timers[luz] <= 0:
			# Inicia uma sequência de piscadas rápidas
			if piscadas_restantes[luz] <= 0:
				piscadas_restantes[luz] = randi_range(2, 6)

			luz.visible = !luz.visible
			piscadas_restantes[luz] -= 1

			if piscadas_restantes[luz] > 0:
				timers[luz] = randf_range(0.03, 0.12)
			else:
				luz.visible = true
				timers[luz] = randf_range(1.0, 5.0)
