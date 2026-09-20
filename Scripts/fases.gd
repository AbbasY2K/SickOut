extends Node2D

func _ready() -> void:

	$shader.show()
	$fase1.grab_focus()

	$voltar.text = Tradutor.get_text("VOLTAR")

	for i in range(0, 11):

		var fase = get_node_or_null("fase%d" % i)

		if fase == null:
			continue

		var nota = fase.get_node_or_null("nota")

		var rank = Global.ranks.get("fase%d" % i, "")

		if nota:

			match rank:

				"S":
					nota.text = "[color=gold][wave amp=15 freq=4]S[/wave][/color]"

				"A":
					nota.text = "[color=lime_green]A[/color]"

				"B":
					nota.text = "[color=deepskyblue]B[/color]"

				"C":
					nota.text = "[color=orange]C[/color]"

				"D":
					nota.text = "[color=red]D[/color]"

				_:
					nota.text = ""

func piscar_botao(botao: Control) -> void:
	$selectBotao.play()

	var cor_original = botao.modulate

	var tween = create_tween()
	for i in range(2):
		tween.tween_property(botao, "modulate", Color.WHITE, 0.04)
		tween.tween_property(botao, "modulate", Color(1, 1, 1, 0.2), 0.04)

	tween.tween_property(botao, "modulate", cor_original, 0.04)


func _on_fase_0_pressed() -> void:
	get_viewport().gui_release_focus()
	piscar_botao($fase0)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	$music.stop()
	get_tree().change_scene_to_file("res://Cenas/Fases/tutorial.tscn")


func _on_fase_1_pressed() -> void:
	get_viewport().gui_release_focus()
	piscar_botao($fase1)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	$music.stop()
	get_tree().change_scene_to_file("res://Cenas/Fases/fase1.tscn")


func _on_fase_2_pressed() -> void:
	get_viewport().gui_release_focus()
	piscar_botao($fase2)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	$music.stop()
	get_tree().change_scene_to_file("res://Cenas/Fases/fase2.tscn")


func _on_fase_3_pressed() -> void:
	get_viewport().gui_release_focus()
	piscar_botao($fase3)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	$music.stop()
	get_tree().change_scene_to_file("res://Cenas/Fases/fase3.tscn")


func _on_fase_4_pressed() -> void:
	get_viewport().gui_release_focus()
	piscar_botao($fase4)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	$music.stop()
	get_tree().change_scene_to_file("res://Cenas/Fases/fase4.tscn")


func _on_fase_5_pressed() -> void:
	get_viewport().gui_release_focus()
	piscar_botao($fase5)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	$music.stop()
	get_tree().change_scene_to_file("res://Cenas/Fases/fase5.tscn")


func _on_fase_6_pressed() -> void:
	get_viewport().gui_release_focus()
	piscar_botao($fase6)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	$music.stop()
	get_tree().change_scene_to_file("res://Cenas/Fases/fase6.tscn")


func _on_fase_7_pressed() -> void:
	get_viewport().gui_release_focus()
	piscar_botao($fase7)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	$music.stop()
	get_tree().change_scene_to_file("res://Cenas/Fases/fase7.tscn")


func _on_fase_8_pressed() -> void:
	get_viewport().gui_release_focus()
	piscar_botao($fase8)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	$music.stop()
	get_tree().change_scene_to_file("res://Cenas/Fases/fase8.tscn")


func _on_fase_9_pressed() -> void:
	get_viewport().gui_release_focus()
	piscar_botao($fase9)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	$music.stop()
	get_tree().change_scene_to_file("res://Cenas/Fases/fase9.tscn")


func _on_voltar_pressed() -> void:
	get_viewport().gui_release_focus()
	piscar_botao($voltar)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("in")
	await get_tree().create_timer(0.5).timeout
	$music.stop()
	get_tree().change_scene_to_file("res://Cenas/Menus/menu.tscn")
