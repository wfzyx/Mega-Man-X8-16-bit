extends Node2D

export var damageNode: NodePath
onready var dmg = get_node_or_null(damageNode)

func damage(damage, inflicter) -> float:
	if dmg != null:
		return dmg.damage(damage, inflicter)
	push_error("Trying to access damage through actual_center but no damage has been set")
	return 0.0
