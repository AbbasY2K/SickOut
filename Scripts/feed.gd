extends Control

@export var mensagem_scene: PackedScene
@export var max_mensagens := 5

var mensagens := [
	"KILL_1",
	"KILL_2",
	"KILL_3",
	"KILL_4",
	"KILL_5",
	"KILL_6",
	"KILL_7",
	"KILL_8",
	"KILL_9",
	"KILL_10",
	"KILL_11",
	"KILL_12",
	"KILL_13",

	"KILL_14",
	"KILL_15",
	"KILL_16",
	"KILL_17",
	"KILL_18",
	"KILL_19",
	"KILL_20",
	"KILL_21",
	"KILL_22",
	"KILL_23",

	"KILL_24",
	"KILL_25",
	"KILL_26",
	"KILL_27",
	"KILL_28",
	"KILL_29",
	"KILL_30",
	"KILL_31",
	"KILL_32"
]

func adicionar_kill():
	var msg = mensagem_scene.instantiate()

	var key = mensagens.pick_random()
	var texto = Tradutor.get_text(key)

	msg.get_node("Label").text = "[shake]" + texto

	$"../killCount".add_count()
	$feed.add_child(msg)
	$feed.move_child(msg, $feed.get_child_count() - 1)

	# Aparição estilo arcade
	msg.modulate.a = 0
	msg.scale = Vector2.ONE * 1.8

	var tween = create_tween()

	tween.tween_property(msg, "modulate:a", 1.0, 0.08)

	tween.parallel().tween_property(
		msg,
		"scale",
		Vector2.ONE * 0.9,
		0.12
	).set_trans(Tween.TRANS_BACK)

	tween.tween_property(msg, "scale", Vector2.ONE, 0.08)

	sumir_mensagem(msg)

	if $feed.get_child_count() > max_mensagens:
		var antiga = $feed.get_child(0)

		if antiga != msg:
			antiga.queue_free()


func sumir_mensagem(msg):
	await get_tree().create_timer(3.0).timeout

	if !is_instance_valid(msg):
		return

	var texto = msg.get_node("Label")

	var tween = create_tween()

	tween.tween_property(texto, "modulate:a", 0.0, 0.25)

	await tween.finished

	if is_instance_valid(msg):
		msg.queue_free()
