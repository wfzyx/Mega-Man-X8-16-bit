extends Node2D
class_name WallEnemyAlarmAwareness

func _ready() -> void:
	Event.listen("alarm",self,"on_alarm")
	Event.listen("turn_off_alarm",self,"on_alarm_off")
	#print(name + ": Connected events for " + ai.get_parent().name)
	pass

func on_alarm() -> void:
	#print("Adding to " + get_parent().get_parent().name)
	get_parent().append_behaviour_to_on_enter_screen_event("../BlockPassage")

func on_alarm_off() -> void:
	get_parent().on_enter_screen.clear()
	pass
