extends CharacterBody2D 
class_name Enemy

enum State {IDLE, HITSTUN, DYING}

@export var max_hp: float = 3.0
@export var low_hp_threshold:float = 1.0
@export var linear_velocity: float = 80
@export var velocity_decay: float = 0.8
@export var knockback_factor: float = 3.0
@export var alert_pack: bool = true
@onready var current_hp = max_hp
@onready var command_velocity = Vector2.ZERO
@onready var response_velocity = Vector2.ZERO
@onready var state: State = State.IDLE
@onready var target:Hero = null
@onready var nearby_friendlies: Dictionary = Dictionary()
func friends() -> Array:
	var friends = nearby_friendlies.keys()
	for friend in friends:
		if not is_instance_valid(friend):
			nearby_friendlies.erase(friend)
			friends.erase(friend)
	return friends

## Maximum distance from the spawn this entity is willing to go
@export var max_chase_distance: float = 500.0
func check_far_from_spawn():
	if position.length() > max_chase_distance:
		target = null
		return true
	else:
		return false

## Maximum distance from a target before the tare
@export var max_target_range: float = 150.0
func target_in_range():
	if target != null:
		if (target.global_position - global_position).length() > max_target_range:
			return true
		else:
			return false
	else:
		return true
func establish_target(body):
	if target == null and not check_far_from_spawn():
		target = body
		$AnimationPlayer.play("exclaim")
	for friend in nearby_friendlies.keys():
		if friend.target == null:
			friend.establish_target(body)

func flee():
	if target != null:
		if target_in_range():
			var offset = global_position - target.global_position
			command_velocity = offset.normalized() * linear_velocity
			return BeehaveTree.RUNNING
		else:
			return BeehaveTree.SUCCESS

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
	if response_velocity.length() > 0:
		response_velocity *= velocity_decay
		if response_velocity.length() < 10:
			response_velocity = Vector2.ZERO
			state = State.IDLE
