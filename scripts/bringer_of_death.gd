class_name BringerOfDeath extends Enemy

const spell_class : PackedScene = preload("res://prefabs/bringer_of_death_spell.tscn")
const E = 2.71828182845904523536028747135266249775724709369995
func awaken ():
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		target = player
func cast_spell( target_position: Vector2 , z_index_offset:int = 0):
	var spell = spell_class.instantiate()
	spell.position = get_parent().to_local(target_position)
	spell.z_index += z_index_offset
	add_sibling(spell)
func cast_spell_scatter( target_position: Vector2, n: int = 20, z_score: float = 100.0, delay: float = 0.1):
	for i in range(n, 0, -1):
		cast_spell(target_position + Vector2( randfn(0, z_score * i / n), randfn(0, z_score * i / n)))
		await get_tree().create_timer(delay).timeout
func cast_spell_cloud( target_position: Vector2, distance: float = 20.0, rotational_step: float = 20.0, delay: float = 0.1):
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
func _ready():
	pass
@export var max_mana: float = 5.0
@onready var mana_pool: float = 5.0
func _process(delta):
	if target != null:
		if mana_pool >= 5.0:
			$AnimatedSprite2D.play("cast")
			cast_spell_spiral( target.global_position, 40, 4.0, 150.0, 0.05 )
			#cast_spell(target.global_position)
			mana_pool -= 5.0
	mana_pool = clamp(mana_pool + delta, 0.0, max_mana)

func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.play("idle")
