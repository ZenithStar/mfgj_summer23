extends Area2D

@export var damage: float = 1.0
@export var knockback: float = 200.0
func _ready():
	$AnimationPlayer.play("fire")

func _on_body_entered(body):
	if body is Hero:
		body.take_hit( damage , (body.global_position - global_position).normalized() * knockback )
