extends CharacterBody2D

const SPEED = 1250
var direction := Vector2.ZERO

func _ready():

	await get_tree().create_timer(0.185).timeout
	queue_free()

func _physics_process(delta):

	var motion = direction * SPEED * delta

	var collision = move_and_collide(motion)

	if collision:

		var obj = collision.get_collider()

		if obj.is_in_group("inimigo"):

			if obj.has_method("morrer_tiro"):
				obj.morrer_tiro(direction.x)

			elif obj.has_method("morrer"):
				obj.morrer(direction.x)

			queue_free()

		elif obj.is_in_group("inimigoGrande"):

			if obj.has_method("_on_inimigo_hit_box_body_entered"):
				obj._on_inimigo_hit_box_body_entered(self)

			queue_free()
