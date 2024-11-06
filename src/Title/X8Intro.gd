extends Node2D
onready var info: Label = $title_card_intro/demo_02

func _ready() -> void:
	info.text = GameManager.current_demo + "\n" + "V." + GameManager.version
