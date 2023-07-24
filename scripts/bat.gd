extends Enemy
class_name Bat

@export var disengage_distance: float = 150
@export var patrol_radius: float = 100
@export var max_chase_distance: float = 500
@export var patrol_angular_velocity: float = .01
@export var linear_velocity: float = 100

@export var wander_rate = 0.1
@onready var patrol_angle: float = randf_range(-PI, PI)
@onready var patrol_angle_i: float = randf_range(-1000.0, 1000.0)
@onready var patrol_velocity_i: float = randf_range(-1000.0, 1000.0)
@onready var noise: FastNoiseLite = FastNoiseLite.new()
func _ready():
	noise.noise_type = FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH
	noise.seed = randi()
	
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

@export var orbit_distance_velocity:float = 1.0
@onready var initial_orbit_distance:float = $Detection/CollisionShape2D.shape.radius / 2
@onready var orbit_duration:float = 0.0
@onready var orbit_distance:float = 0.0
@onready var orbit_direction:float = 0.0
@onready var orbit_distance_i: float = randf_range(-1000.0, 1000.0)
func preorbit():
	orbit_distance = initial_orbit_distance
	orbit_direction = 1.0 if randf() < 0.5 else -1.0
	orbit_distance_i = randf_range(-1000.0, 1000.0) 
	return BeehaveTree.SUCCESS
func orbit():
	var offset = target.global_position - global_position
	if ( target == null ) || ( max_chase_distance < offset.length() ):
		return BeehaveTree.SUCCESS
	else:
		command_velocity = offset.normalized().orthogonal() * orbit_direction * linear_velocity
		orbit_distance += noise.get_noise_1d(orbit_distance_i) * orbit_distance_velocity
		orbit_distance = ( orbit_distance + initial_orbit_distance ) / 2.0
		command_velocity += (offset.length() - orbit_distance) * offset.normalized()
		return BeehaveTree.RUNNING
func orbital_charge():
	orbit_distance -= orbit_distance_velocity
	return orbit()
