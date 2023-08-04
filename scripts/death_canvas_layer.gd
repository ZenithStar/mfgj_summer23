extends CanvasLayer

func _ready():
	$DeathScreen/VBoxContainer/HPHBoxContainer/HPLabel.text = str(int(Globals.hp_scale)) + "00%"
	$DeathScreen/VBoxContainer/DamageHBoxContainer/DamageLabel.text = str(int(Globals.damage_scale)) + "00%"

func enable():
	visible = true
	process_mode = PROCESS_MODE_INHERIT
func disable():
	visible = false
	process_mode = PROCESS_MODE_DISABLED

func restart():
	get_tree().reload_current_scene()

func _on_gitgud_pressed():
	restart()

func _on_hp_pressed():
	Globals.hp_scale += 1.0
	restart()

func _on_damage_pressed():
	Globals.damage_scale += 1.0
	restart()
