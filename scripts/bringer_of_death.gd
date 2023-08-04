class_name BringerOfDeath extends Enemy

const spell_class : PackedScene = preload("res://prefabs/bringer_of_death_spell.tscn")
const blast_class : PackedScene = preload("res://prefabs/death_blast.tscn")
const bat_class : PackedScene = preload("res://prefabs/bat.tscn")
const fireball_class : PackedScene = preload("res://prefabs/fire.tscn")
const E = 2.71828182845904523536028747135266249775724709369995

enum BringerOfDeathStates {
	INACTIVE,
	ACTIVE,
	BUSY, # All actions are handled by the AnimationPlayer
	CASTING,
}
enum BringerOfDeathPhase {
	FIRST,
	SECOND,
	FINAL
}
@onready var action_state: BringerOfDeathStates = BringerOfDeathStates.ACTIVE
func awaken ():
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		target = player
		action_state = BringerOfDeathStates.ACTIVE
func cast_spell( target_position: Vector2 , z_index_offset:int = 0):
	var spell = spell_class.instantiate()
	spell.position = get_parent().to_local(target_position)
	spell.z_index += z_index_offset
	add_sibling(spell)
func cast_spell_scatter( target_position: Vector2, n: int = 20, z_score: float = 100.0, delay: float = 0.1):
	for i in range(n, 0, -1):
		cast_spell(target_position + Vector2( randfn(0, z_score * i / n), randfn(0, z_score * i / n)))
		await get_tree().create_timer(delay).timeout
func cast_spell_stream( target_position: Vector2, distance: float = 20.0, rotational_step: float = 20.0, delay: float = 0.1):
	pass
func cast_spell_spiral( target_position: Vector2, n: int = 20, loops:float = 2.0, radius: float = 100.0, delay: float = 0.1):
	var final = E ** loops
	var orientation_offset = randf_range(0,TAU)
	for i in range(n, 0, -1):
		var magnitue = log(final * i / n)
		var rot = magnitue * TAU + orientation_offset
		var orientation = Vector2(cos(rot), -sin(rot))
		var length = radius * magnitue / loops
		cast_spell(target_position + orientation * length, i)
		await get_tree().create_timer(delay).timeout
@export var smash_blast_offset : Vector2 = Vector2(-64, 42)
func smash_blast( target_position: Vector2, radius: float = 250.0):
	var blast = blast_class.instantiate()
	blast.position = get_parent().to_local(target_position)
	blast.blast_radius = radius
	add_sibling(blast)
func spawn_bat( z_score: float = 40.0):
	var bat = bat_class.instantiate()
	bat.position = get_parent().to_local(global_position) + Vector2( randfn(0, z_score ), randfn(0, z_score ))
	var tween = get_tree().create_tween()
	var bat_c = bat.get_child(0)
	bat_c.modulate.a = 0.0
	bat_c.target = target
	bat_c.max_target_range = 1000000.0
	bat_c.temporary = true
	tween.bind_node(bat_c)
	tween.tween_property(bat_c, "modulate", Color.WHITE, 0.2)
	tween.tween_property(bat_c, "target", target, 0.0)
	add_sibling(bat)
	tween.play()
func danmaku_stream( n:int = 20, projectile_velocity: float = 200.0, delay:float = 0.1):
	for i in n:
		var fireball = fireball_class.instantiate()
		var orientation = target.global_position - global_position
		fireball.position = get_parent().to_local(global_position)
		fireball.rotation = atan2(-orientation.y, orientation.x)
		fireball.velocity = orientation.normalized() * projectile_velocity
		add_sibling(fireball)
		await get_tree().create_timer(delay).timeout
func danmaku_curtain( n:int = 10, projectile_velocity: float = 200.0, delay:float = 0.1):
	for i in range(n*2, 0, -1):
		var fireball = fireball_class.instantiate()
		var rotation_offset = (PI/2 * (n-i) / n) * (-1 if i % 2 == 0 else 1)
		var orientation = (target.global_position - global_position).rotated(rotation_offset)
		fireball.position = get_parent().to_local(global_position)
		fireball.rotation = atan2(-orientation.y, orientation.x)
		fireball.velocity = orientation.normalized() * projectile_velocity
		add_sibling(fireball)
		await get_tree().create_timer(delay).timeout

func _ready():
	death_signal.connect(death)
@export var max_mana: float = 5.0
@onready var mana_pool: float = 5.0
@onready var mana_regen: float = 5.0
@onready var stage: int = 1
const spells: Array[String] = ["huge_swing", "huge_spell", "teleport_and_spawn_bats", "danmaku"]
#const spells: Array[String] = ["huge_swing", "danmaku"]

func _process(delta):
	if target != null &&  action_state == BringerOfDeathStates.ACTIVE:
		if mana_pool >= 5.0:
			var i: int = randi() % spells.size()
			$AnimationPlayer.play(spells[i])
			mana_pool -= 5.0
	mana_pool = clamp(mana_pool + delta, 0.0, max_mana)
	if $AnimationPlayer.current_animation == "":
		match action_state:
			BringerOfDeathStates.ACTIVE:
				if command_velocity.length() > 0:
					$AnimatedSprite2D.play("walk")
				else :
					$AnimatedSprite2D.play("idle")

# arg-free abilites
func contextual_smash_blast():
	var offset = smash_blast_offset
	if $AnimatedSprite2D.flip_h:
		smash_blast_offset *= Vector2(-1.0, 1.0)
	smash_blast(offset + global_position)
func contextual_cast_spell():
	var spell_duration = 2.5
	var n = 4 * stage
	cast_spell_spiral( target.global_position, n * 10, n, 150.0, spell_duration / 10 / n )
func contextual_spawn_bats():
	var n = 5 * stage
	for i in n:
		spawn_bat()
func contextual_danmaku():
	danmaku_stream()
	danmaku_curtain()
func nothing_personel_kid():
	global_position = (target.global_position - global_position).normalized() * 30.0 + target.global_position
func death():
	pass
