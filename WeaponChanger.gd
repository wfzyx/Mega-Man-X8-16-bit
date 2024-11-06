extends Node
class_name WeaponChanger

export var active := false
onready var character = get_parent()

func _process(_delta: float) -> void:
	if active:
		if Input.is_action_just_pressed("weapon_select_left"):
			Event.emit_signal("weapon_select_left")
		elif Input.is_action_just_pressed("weapon_select_right"):
			Event.emit_signal("weapon_select_right")
		
		if Input.is_action_pressed("weapon_select_left") and \
		   Input.is_action_just_pressed("weapon_select_right") or \
		   Input.is_action_pressed("weapon_select_right") and \
		   Input.is_action_just_pressed("weapon_select_left") or \
		   Input.is_action_just_pressed("reset_weapon"):
			Event.emit_signal("weapon_select_buster")
