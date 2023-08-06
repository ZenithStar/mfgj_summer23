extends CharacterBody2D 
class_name Enemy

enum State {ACTIVE, HITSTUN, DYING}

@export var max_hp: float = 3.0
@export var low_hp_threshold:float = 1.0
@export var max_linear_velocity: float = 80
@export var min_linear_velocity : float = 40
@export var velocity_decay: float = 0.9
@export var knockback_factor: float = 3.0
@export var alert_pack: bool = true
@export var hitstun_duration: float = 0.1
@export var touch_damage: bool = true
@export var temporary: bool = false
@onready var current_hp = max_hp
@onready var command_velocity = Vector2.ZERO
@onready var response_velocity = Vector2.ZERO
@onready var state: State = State.ACTIVE
@onready var target:Hero = null
@onready var noise: FastNoiseLite = FastNoiseLite.new()
func _ready():
	noise.noise_type = FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH
	noise.seed = randi()
	
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
		var exclaim_player = get_node("ExclamationAnimationPlayer")
		if exclaim_player != null:
			exclaim_player.play("exclaim")
		var alert_sfx = get_node("AlertedSFX")
		if alert_sfx != null:
			alert_sfx.play()
		if alert_pack:
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
	if state == State.ACTIVE:
		if current_hp < max_hp:
			if not temporary:
				current_hp = clamp(current_hp + recovery_rate * get_physics_process_delta_time(), 0.0, max_hp)
			else:
				if current_hp <= 0:
					state = State.DYING
					death_signal.emit()
			command_velocity = Vector2.ZERO
			$AnimationPlayer.play("healing")
			return BeehaveTree.RUNNING
		else:
			return BeehaveTree.SUCCESS
	else:
		return BeehaveTree.FAILURE
		
signal death_signal
func take_hit(damage: float, knockback: Vector2, source: Hero) -> bool:
	if state == State.ACTIVE:
		current_hp -= damage
		response_velocity += knockback * knockback_factor
		if current_hp <= 0:
			state = State.DYING
			death_signal.emit()
		else:
			if hitstun_duration > 0.0:
				state = State.HITSTUN
				get_tree().create_timer(hitstun_duration).timeout.connect(func(): state = State.ACTIVE)
			var ani_player = $AnimationPlayer
			if ani_player != null && ani_player.has_animation("damaged"):
				ani_player.play("damaged")
			if target == null:
				establish_target(source)
		$HitSFX.play()
		return true
	else:
		return false
@export var lifespan : float = 60.0 ## if temporary, how long it'll take to die
func _process(delta):
	if temporary:
		current_hp -= max_hp / lifespan * delta
	if command_velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
		
@onready var current_collision: KinematicCollision2D = null
func _physics_process(delta):
	velocity = command_velocity + response_velocity
	current_collision = move_and_collide(velocity * delta)
	if touch_damage && current_collision != null:
		var collider = current_collision.get_collider()
		if collider is Hero:
			collider.take_hit(0.5, velocity)
			response_velocity = velocity.bounce(current_collision.get_normal()).normalized() * max_linear_velocity
	if response_velocity.length() > 0:
		response_velocity *= velocity_decay
		if response_velocity.length() < 10:
			response_velocity = Vector2.ZERO
			if state == State.HITSTUN:
				state = State.ACTIVE
