extends CharacterBody2D
class_name Hero

@export var speed = 100
@export var velocity_decay: float = 0.8
@export var move_left: String = "move_left"
@export var move_right: String = "move_right"
@export var move_up: String = "move_up"
@export var move_down: String = "move_down"
@export var action_left: String = "action_left"
@export var action_right: String = "action_right"
@export var action_up: String = "action_up"
@export var action_down: String = "action_down"
@export var action: String = "action"
@export var action_mouse: String = "action_mouse"

enum State {ACTIVE, IMMUNE}
@onready var state: State = State.ACTIVE

var sword_class : PackedScene = preload("res://prefabs/sword.tscn")

@onready var last_direction: String = "_down"
@onready var attacking:bool = false
@onready var sword: SwordSwing = null
@onready var last_move_vector: Vector2 = Vector2(0.0,1.0)
@onready var external_impulse: Vector2 = Vector2.ZERO
@onready var current_hp = Globals.life

func _physics_process(_delta):
	var input_direction = Input.get_vector(move_left, move_right, move_up, move_down)
	var action_direction = Input.get_vector(action_left, action_right, action_up, action_down)
	if input_direction.length() > 0:
		if input_direction.x != 0:
			if input_direction.x > 0:
				$AnimatedSprite2D.flip_h = false
			else:
				$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("run")
		last_move_vector = input_direction
	else:
		$AnimatedSprite2D.play("idle")
	if action_direction.length() > 0:
		if sword == null:
			sword = sword_class.instantiate()
			sword.rotation = atan2(action_direction.y, action_direction.x)
			add_child(sword)
	if Input.is_action_pressed(action):
		if sword == null:
			sword = sword_class.instantiate()
			sword.rotation = atan2(last_move_vector.y, last_move_vector.x)
			add_child(sword)
	if Input.is_action_pressed(action_mouse):
		if sword == null:
			sword = sword_class.instantiate()
			var offset = get_global_mouse_position() - global_position
			sword.rotation = atan2(offset.y, offset.x)
			add_child(sword)
	velocity = input_direction * speed + external_impulse
	move_and_slide()
	if state == State.IMMUNE:
		external_impulse *= velocity_decay
		if external_impulse.length() < 10:
			external_impulse = Vector2.ZERO
			state = State.ACTIVE

func take_hit(damage: int, knockback: Vector2):
	if state == State.ACTIVE:
		current_hp -= damage
		external_impulse = knockback 
		state = State.IMMUNE
		$AnimationPlayer.play("damaged")
		$HitSFX.play()
			
