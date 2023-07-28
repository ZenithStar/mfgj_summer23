extends Area2D
class_name SwordSwing

@export var lifespan = 0.3
@export var swing_angle = 90.0
@export var radius_offset = 6.0
@export var damage: float = 1.0
@export var knockback = 100.0

@onready var elapsed = 0.0

func _physics_process(delta):
	elapsed += delta
	if elapsed > lifespan:
		queue_free()
	rotation_degrees += swing_angle * delta / lifespan

func _on_body_entered(body):
	var angle = rotation + $CollisionShape2D.rotation
	if body is Enemy:
		body.take_hit( damage , knockback * Vector2(sin(angle), -cos(angle)) , get_parent())
