extends Node

var lista1 = preload("res://Scripts/Global/traducao1.gd").new()
var lista2 = preload("res://Scripts/Global/traducao2.gd").new()
var lista3 = preload("res://Scripts/Global/traducao3.gd").new()
var lista4 = preload("res://Scripts/Global/traducao4.gd").new()

func get_text(key: String) -> String:
	var result = lista1.get_text(key)
	if not result.begins_with("[MISSING"):
		return result

	result = lista2.get_text(key)
	if not result.begins_with("[MISSING"):
		return result

	result = lista3.get_text(key)
	if not result.begins_with("[MISSING"):
		return result
	
	result = lista4.get_text(key)
	if not result.begins_with("[MISSING"):
		return result

	return "[MISSING KEY: %s]" % key
