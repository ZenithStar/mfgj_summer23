extends CanvasLayer

@export var health_origin: Vector2 = Vector2( 50.0 , 50.0)
@export var health_icon_increment: Vector2 = Vector2( 24.0 , 0.0)

var health_icon_class : PackedScene = preload("res://prefabs/health_ui_icon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range( int(Globals.life) ):
		var icon = health_icon_class.instantiate()
		icon.position = health_origin + health_icon_increment * i
		add_child(icon)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
