extends CharacterBody2D
class_name Hero

@export var speed = 100
@export var move_left: String = "move_left"
@export var move_right: String = "move_right"
@export var move_up: String = "move_up"
@export var move_down: String = "move_down"
@export var action: String = "action"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


static var last_direction: String = "_down"
func _physics_process(delta):
	var input_direction = Input.get_vector(move_left, move_right, move_up, move_down)
	velocity = input_direction * speed
	if velocity.length() > 0:
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
	else:
		animated_sprite.play("idle" + last_direction)
	
	move_and_slide()
