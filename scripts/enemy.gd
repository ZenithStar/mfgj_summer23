extends CharacterBody2D 
class_name Enemy

enum State {IDLE, HITSTUN, DYING}

@export var max_hp: float = 3.0
@export var low_hp_threshold:float = 1.0
@export var max_linear_velocity: float = 80
@export var min_linear_velocity : float = 40
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
	var friends_list = nearby_friendlies.keys()
	for friend in friends_list:
		if not is_instance_valid(friend):
			nearby_friendlies.erase(friend)
	friends_list = nearby_friendlies.keys()
	return friends_list

## decay velocity relative to health loss
func decayed_velocity() -> float:
	return min_linear_velocity + (max_linear_velocity - min_linear_velocity) * current_hp / max_hp

## Maximum distance from the spawn this entity is willing to go
@export var max_chase_distance: float = 500.0
func check_far_from_spawn() -> bool:
	if position.length() > max_chase_distance:
		target = null
		return true
	else:
		return false

## Maximum distance from a target before the tare
@export var max_target_range: float = 150.0
func target_in_range(distance: float = max_target_range) -> bool:
	if target != null:
		if (target.global_position - global_position).length() > distance:
			return false
		else:
			return true
	else:
		return false
func establish_target(body):
	if target == null and not check_far_from_spawn():
		target = body
		$AnimationPlayer.play("exclaim")
		for friend in friends():
			if friend.target == null:
				friend.establish_target(body)

func flee():
	if target != null:
		if target_in_range():
			var offset = global_position - target.global_position
			command_velocity = offset.normalized() * decayed_velocity() 
			return BeehaveTree.RUNNING
		else:
			return BeehaveTree.SUCCESS
	else:
		return BeehaveTree.SUCCESS
		
func disengage():
	if target != null:
		if target_in_range(50.0):
			var offset = global_position - target.global_position
			command_velocity = offset.normalized() * decayed_velocity() 
			return BeehaveTree.RUNNING
		else:
			return BeehaveTree.SUCCESS
	else:
		return BeehaveTree.FAILURE
		
@export var recovery_rate:float = 0.5
func recover():
	if current_hp < max_hp:
		current_hp = clamp(current_hp + recovery_rate * get_physics_process_delta_time(), 0.0, max_hp)
		command_velocity = Vector2.ZERO
		$AnimationPlayer.play("healing")
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
			$AnimationPlayer.play("damaged")
			response_velocity += knockback * knockback_factor

func _process(_delta):
	if command_velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
		
@onready var current_collision: KinematicCollision2D = null
func _physics_process(delta):
	velocity = command_velocity + response_velocity
	current_collision = move_and_collide(velocity * delta)
	if current_collision != null:
		var collider = current_collision.get_collider()
		if collider is Hero:
			collider.take_hit(0.5, velocity)
			response_velocity = velocity.bounce(current_collision.get_normal()).normalized() * max_linear_velocity
	if response_velocity.length() > 0:
		response_velocity *= velocity_decay
		if response_velocity.length() < 10:
			response_velocity = Vector2.ZERO
			state = State.IDLE
