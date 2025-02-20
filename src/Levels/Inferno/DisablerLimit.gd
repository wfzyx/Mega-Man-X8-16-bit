extends CameraLimits

export (NodePath) var limit_to_disable

func _ready() -> void:
	connect("body_entered",self,"start_disable_timer")# warning-ignore:return_value_discarded

func start_disable_timer(_body) -> void:
	if limit_to_disable:
		var timer = get_tree().create_timer(0.5)
		timer.connect("timeout",self,"disable_limit")

func disable_limit() -> void:
	get_node(limit_to_disable).disable()
	
