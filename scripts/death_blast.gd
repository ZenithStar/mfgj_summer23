extends Node2D

var target : Hero
@export var blast_radius : float = 250.0
@export var blast_magnitude : float = 16.0
@export var blast_duration : float = 3.0
@export var damage : float = 0.2
@export var knockback : float = 100.0
@onready var texture_radius: float = $PointLight2D.texture.get_height() / 2.0
@onready var elapsed : float = 0.0
func _ready():
	target = get_tree().get_first_node_in_group("Player")
	$PointLight2D.texture_scale = blast_radius / texture_radius
func _process(delta):
	var progress: float = 0.0
	if elapsed < blast_duration:
		progress = elapsed / blast_duration
	elif elapsed < blast_duration * 2:
		progress = (((blast_duration * 2) - elapsed) / blast_duration)**2
	else:
		queue_free()
	$RayCast2D.target_position = (target.global_position - $RayCast2D.global_position).normalized() * blast_radius * progress
	$PointLight2D.energy = blast_magnitude * progress
	var c: float=  1-progress
	$CanvasModulate.color = Color( c,c,c )
	elapsed += delta

func _physics_process(delta):
	var collider = $RayCast2D.get_collider()
	if collider is Hero:
		collider.take_hit(damage, knockback*(target.global_position - $RayCast2D.global_position).normalized())
