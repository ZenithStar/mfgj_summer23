extends CharacterBody2D 
class_name Enemy

enum State {IDLE, HITSTUN, DYING}

@export var max_hp: int = 100
@export var velocity_decay: float = 0.8
@export var knockback_factor: float = 3.0
@onready var current_hp = max_hp
@onready var state: State = State.IDLE


func take_hit(damage: int, knockback: Vector2):
	if state != State.HITSTUN:
		current_hp -= damage
		if current_hp <= 0:
			# TODO: dying animation
			state = State.DYING
			queue_free()
		else:
			state = State.HITSTUN
			velocity = knockback * knockback_factor

func _physics_process(delta):
	move_and_slide()
	if state == State.HITSTUN:
		velocity *= velocity_decay
		if velocity.length() < 10:
			velocity = Vector2.ZERO
			state = State.IDLE
