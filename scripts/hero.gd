extends CharacterBody2D
class_name Hero

@export var speed = 100
@export var velocity_decay: float = 0.9
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

enum State {ACTIVE, IMMUNE, DEAD}
@onready var state: State = State.ACTIVE
@export var immunity_duration: float = 0.5

const sword_class : PackedScene = preload("res://prefabs/sword.tscn")
const sword_beam_class : PackedScene = preload("res://prefabs/sword_beam.tscn")

@onready var last_direction: String = "_down"
@onready var attacking:bool = false
@onready var sword: SwordSwing = null
@onready var last_move_vector: Vector2 = Vector2(0.0,1.0)
@onready var external_impulse: Vector2 = Vector2.ZERO
@onready var max_hp: float = Globals.hp_scale - 0.01
@onready var current_hp:float = max_hp
@export var zoom_rate: float = pow(2.0, 1.0/10.0)
func _unhandled_input(event):
	if event.is_action("zoom_in"):
		$Camera2D.zoom = $Camera2D.zoom * zoom_rate
	elif event.is_action("zoom_out"):
		$Camera2D.zoom = $Camera2D.zoom / zoom_rate
		

func attack(direction):
	if sword == null:
		$SwordSFX.play()
		sword = sword_class.instantiate()
		sword.damage *= Globals.damage_scale
		sword.rotation = atan2(direction.y, direction.x)
		add_child(sword)
		var sword_beam = sword_beam_class.instantiate()
		sword_beam.damage *= Globals.damage_scale
		sword_beam.set_direction(direction)
		add_child(sword_beam)

func _physics_process(_delta):
	var input_direction = Input.get_vector(move_left, move_right, move_up, move_down)
	var action_direction = Input.get_vector(action_left, action_right, action_up, action_down)
	if state != State.DEAD:
		if input_direction.length() > 0:
			if input_direction.x != 0:
				if input_direction.x > 0:
					$AnimatedSprite2D.flip_h = false
				else:
					$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("run")
			if !$StepsSFX.playing:
				$StepsSFX.play()
			last_move_vector = input_direction
		else:
			$AnimatedSprite2D.play("idle")
			$StepsSFX.stop()
		if action_direction.length() > 0:
			attack(action_direction)
		if Input.is_action_pressed(action):
			attack(last_move_vector)
		if Input.is_action_pressed(action_mouse):
			var offset = get_global_mouse_position() - global_position
			attack(offset)
		velocity = input_direction * speed + external_impulse
		move_and_slide()
	if external_impulse.length() >= 10:
		external_impulse *= velocity_decay
		if external_impulse.length() < 10:
			external_impulse = Vector2.ZERO

func take_hit(damage: float, knockback: Vector2):
	if state == State.ACTIVE:
		current_hp -= damage
		external_impulse = knockback 
		$AnimationPlayer.play("damaged")
		$HitSFX.play()
		if current_hp < 0:
			state = State.DEAD
			var tween = get_tree().create_tween()
			tween.tween_property($AnimatedSprite2D, "modulate", Color.BLACK, 0.5)
			$DeathCanvasLayer.enable()
		else:
			state = State.IMMUNE
			await get_tree().create_timer(immunity_duration).timeout
			state = State.ACTIVE
