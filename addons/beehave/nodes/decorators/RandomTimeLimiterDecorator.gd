@tool
@icon("../../icons/limiter.svg")
class_name RandomTimeLimiterDecorator extends TimeLimiterDecorator

@export var min_wait_time: float = 4.0
@export var max_wait_time: float = 10.0

func _ready():
	wait_time = randf_range(min_wait_time, max_wait_time)

