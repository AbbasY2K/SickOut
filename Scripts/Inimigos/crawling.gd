extends Inimigo


@export var SPEED := 100.0


func _ready():

	super._ready()

	VIRAR_COM_COLISAO = false

	await get_tree().create_timer(10.0).timeout

	if is_inside_tree():
		queue_free()


func processar_ia(_delta):

	velocity.x = SPEED * direction

	atualizar_direcao()


func _on_hit_box_body_entered(body):

	if body.has_method("freezePlayer") and not body.invencivel:

		body.get_parent().gameover()
