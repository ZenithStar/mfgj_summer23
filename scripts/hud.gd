extends CanvasLayer

var health_icon_class : PackedScene = preload("res://prefabs/health_ui_icon.tscn")

func _ready():
	pass
	# for i in range( int(Globals.life) ):
		#var icon = health_icon_class.instantiate()
		#$HealthContainer.add_child(icon)

func _process(_delta):
	$Debug/FPS.text = "FPS: " + str(Engine.get_frames_per_second())
