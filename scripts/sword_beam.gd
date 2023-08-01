extends Area2D
class_name SwordBeam

@export var linear_velocity = 500.0
@export var velocity: Vector2 = Vector2(500.0,0.0)
@export var lifespan: float = 0.3
@export var damage: float = 0.5
@export var knockback: float = 100.0

@onready var elapsed = 0.0

func set_direction(direction):
	rotation = atan2(direction.y, direction.x)
	velocity = direction.normalized() * linear_velocity
	
func _physics_process(delta):
	elapsed += delta
	if elapsed > lifespan:
		queue_free()
	position += velocity * delta
	
func _on_body_entered(body):
	if body is Enemy:
		body.take_hit( damage , velocity.normalized() * knockback , get_parent())
