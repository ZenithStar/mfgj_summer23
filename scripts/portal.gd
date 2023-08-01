## An Area2D that acts as a transition between two layers by setting collision layers and masks. If both modulate areas are set, this node will use the modulate parameter to fade between the two areas as the player moves through it.
class_name Portal extends Area2D

@export var first_modulate_area : CanvasItem = null ## modulate target
@export_flags_2d_physics var first_area_layers : int = 1
@export var second_modulate_area : CanvasItem = null ## modulate target
@export_flags_2d_physics var second_area_layers : int = 2
@export var direction: Vector2 = Vector2(1.0, 0.0) ## The intended direction to move from first_area towards second_area
@export var player_body: CollisionObject2D = null ## The body that this portal will look for to modulate between visible layers

@onready var active = false
@onready var this_shape: CollisionShape2D = null
@onready var other_shape: CollisionShape2D = null
@onready var other_shape_max_depth: float
func _process(delta):
	if active:
		var contacts = this_shape.shape.collide_and_get_contacts(this_shape.global_transform, other_shape.shape, other_shape.global_transform)
		if contacts.size != 0:
			# just assume that the first contact works
			var depth = (contacts[1] - contacts[0]).dot(direction) * direction # projection onto direction
			if depth < 0:
				second_modulate_area.modulate.a = clamp( depth / other_shape_max_depth, 0.0, 1.0) 
				first_modulate_area.a = 1.0
			if depth > 0:
				first_modulate_area.modulate.a = clamp( depth / other_shape_max_depth, 0.0, 1.0) 
				second_modulate_area.a = 1.0

func _on_body_entered(body):
	if body is PhysicsBody2D:
		body.collision_layer |= first_area_layers | second_area_layers
		body.collision_mask |= first_area_layers | second_area_layers
		if body == player_body && first_modulate_area != null && second_modulate_area != null:
			for child in get_children():
				if child is CollisionShape2D:
					this_shape = child
					continue
			for child in body.get_children():
				if child is CollisionShape2D:
					other_shape = child
					# approximate max_depth using rectangular bounding box
					var other_rect: Rect2 = other_shape.shape.get_rect()
					other_shape_max_depth = max(other_rect.size.x, other_rect.size.y) 
					continue
			if this_shape != null && other_shape != null:
				active = true

func _on_body_exited(body):
	if body is PhysicsBody2D:
		if ( body.global_position - global_position ).dot(direction) > 0 :
			body.collision_layer &= ~second_area_layers
			body.collision_mask &= ~second_area_layers
		else:
			body.collision_layer &= ~first_area_layers
			body.collision_mask &= ~first_area_layers
		if body == player_body && active:
			if first_modulate_area.modulate.a < second_modulate_area.modulate.a:
				first_modulate_area.modulate.a = 0.0
				second_modulate_area.modulate.a = 1.0
			else:
				first_modulate_area.modulate.a = 1.0
				second_modulate_area.modulate.a = 0.0
			active = false
