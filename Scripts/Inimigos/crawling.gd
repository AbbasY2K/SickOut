extends CharacterBody2D

@export var SPEED := 100.0

var direction := -1

func _ready():

	await get_tree().create_timer(10.0).timeout
	queue_free()

func _physics_process(delta):

	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = SPEED * direction

	$Sprite2D.flip_h = direction > 0

	move_and_slide()

func _on_hit_box_body_entered(body):

	if body.has_method("freezePlayer") and not body.invencivel:
		body.get_parent().gameover()
