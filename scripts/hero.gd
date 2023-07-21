extends CharacterBody2D
class_name Hero

@export var speed = 100
@export var move_left: String = "move_left"
@export var move_right: String = "move_right"
@export var move_up: String = "move_up"
@export var move_down: String = "move_down"
@export var action: String = "action"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var sword_offset = 6

var sword_class : PackedScene = preload("res://prefabs/sword.tscn")

var last_direction: String = "_down"
var attacking:bool = false
var sword: SwordSwing = null
var last_move_vector: Vector2 = Vector2(0.0,1.0)
func _physics_process(_delta):
	var input_direction = Input.get_vector(move_left, move_right, move_up, move_down)
	if input_direction.length() > 0:
		var animation = ""
		animation = "walk"
		if input_direction.x != 0:
			animation += "_left"
			last_direction = "_left"
			if input_direction.x > 0:
				animated_sprite.flip_h = true
			else:
				animated_sprite.flip_h = false
		elif input_direction.y < 0:
			animation += "_up"
			last_direction = "_up"
		elif input_direction.y > 0:
			animation += "_down"
			last_direction = "_down"
		animated_sprite.play(animation)
		last_move_vector = input_direction
	else:
		animated_sprite.play("idle" + last_direction)
	if Input.is_action_pressed(action):
		if sword == null:
			sword = sword_class.instantiate()
			sword.rotation = atan2(last_move_vector.y, last_move_vector.x)
			add_child(sword)
	velocity = input_direction * speed
	move_and_slide()
