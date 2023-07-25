extends Enemy
class_name Bat

@onready var noise: FastNoiseLite = FastNoiseLite.new()
func _ready():
	noise.noise_type = FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH
	noise.seed = randi()

@export var wander_rate:float = 0.1
@export var patrol_radius: float = 100
@export var patrol_angular_velocity: float = .01
@onready var patrol_angle: float = randf_range(-PI, PI)
@onready var patrol_angle_i: float = randf_range(-1000.0, 1000.0)
@onready var patrol_velocity_i: float = randf_range(-1000.0, 1000.0)

func patrol():
	patrol_angle += noise.get_noise_1d(patrol_angle_i) * patrol_angular_velocity
	var lin_vel = noise.get_noise_1d(patrol_velocity_i) * linear_velocity
	command_velocity = Vector2(sin(patrol_angle), cos(patrol_angle)) * lin_vel
	var patrol_limit_vec: Vector2 = position
	var patrol_limit_mag = patrol_limit_vec.length() - patrol_radius
	if patrol_limit_mag > 0:
		var patrol_limit_effect = patrol_limit_vec.normalized() * -patrol_limit_mag
		command_velocity = (command_velocity + patrol_limit_effect).limit_length(linear_velocity)
	patrol_angle_i += wander_rate
	patrol_velocity_i += wander_rate
	return BeehaveTree.RUNNING

@export var orbit_distance_velocity:float = 0.1
@onready var initial_orbit_distance:float = $Detection/CollisionShape2D.shape.radius / 2
@onready var orbit_duration:float = 0.0
@onready var orbit_distance:float = 0.0
@onready var orbit_direction:float = 0.0
@onready var orbit_distance_i: float = randf_range(-1000.0, 1000.0)
@onready var personal_space_threshold = $CollisionShape2D.shape.radius * 3.0
func preorbit():
	orbit_distance = initial_orbit_distance
	orbit_direction = 1.0 if randf() < 0.5 else -1.0
	orbit_distance_i = randf_range(-1000.0, 1000.0) 
	return BeehaveTree.SUCCESS
func orbit(charge:bool = false):
	var offset = target.global_position - global_position
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Hero:
			return BeehaveTree.SUCCESS
	if max_chase_distance < offset.length():
		target = null
		return BeehaveTree.FAILURE
	elif target == null :
		return BeehaveTree.FAILURE
	else:
		if charge:
			command_velocity = (( offset.normalized().orthogonal() * orbit_direction * offset.length() / initial_orbit_distance ) + offset.normalized()).normalized() * linear_velocity
			return BeehaveTree.RUNNING
		else:
			command_velocity = offset.normalized().orthogonal() * orbit_direction * linear_velocity
			orbit_distance += noise.get_noise_1d(orbit_distance_i) * orbit_distance_velocity
			orbit_distance_i += wander_rate
			command_velocity += (offset.length() - orbit_distance) * offset.normalized()
			for friend in friends():
				var personal_space = global_position - friend.global_position
				if personal_space.length() < personal_space_threshold:
					command_velocity += personal_space.normalized().orthogonal() * personal_space_threshold / personal_space.length() * linear_velocity
			if command_velocity.length() > linear_velocity:
				command_velocity = command_velocity.normalized() * linear_velocity
			return BeehaveTree.RUNNING
