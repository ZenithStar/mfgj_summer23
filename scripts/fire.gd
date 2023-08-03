extends Area2D

@export var damage: float = 0.25
@export var knockback: float = 50.0
@export var velocity: Vector2 = Vector2.RIGHT * 200
@export var lifespan: float = 5.0
func _ready():
	get_tree().create_timer(lifespan).timeout.connect(func():queue_free())
	
func _physics_process(delta):
	position += velocity * delta
	
func _on_body_entered(body):
	if body is Hero :
		body.take_hit( damage , (body.global_position - global_position).normalized() * knockback )
	$AnimationPlayer.play("explode")
