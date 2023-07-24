extends CharacterBody2D 
class_name Enemy

enum State {IDLE, HITSTUN, DYING}

@export var max_hp: int = 100
@export var velocity_decay: float = 0.8
@export var knockback_factor: float = 3.0
@onready var current_hp = max_hp
@onready var command_velocity = Vector2.ZERO
@onready var response_velocity = Vector2.ZERO
@onready var state: State = State.IDLE
@onready var nearby_friendlies: Dictionary = Dictionary()

@export var low_hp_threshold:float = 30
@onready var target:Hero = null

func establish_target(body):
	if target == null:
		target = body
	# exclaim()

func take_hit(damage: int, knockback: Vector2):
	if state != State.HITSTUN:
		current_hp -= damage
		if current_hp <= 0:
			# TODO: dying animation
			state = State.DYING
			queue_free()
		else:
			state = State.HITSTUN
			response_velocity += knockback * knockback_factor

func _process(_delta):
	if command_velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

func _physics_process(_delta):
	velocity = command_velocity + response_velocity
	if move_and_slide():
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is Hero:
				collider.take_hit(10, velocity)
				response_velocity += velocity.bounce(collision.get_normal())
	if state == State.HITSTUN:
		response_velocity *= velocity_decay
		if response_velocity.length() < 10:
			response_velocity = Vector2.ZERO
			state = State.IDLE
