extends ProgressBar
class_name HealthPlate

func _ready():
	visible = false

func _process(_delta):
	max_value = get_parent().max_hp
	value = get_parent().current_hp
	if value < max_value:
		visible = true
