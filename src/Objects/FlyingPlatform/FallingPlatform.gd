extends KinematicBody2D

var falling := false
onready var collision_shape_2d: CollisionShape2D = $collisionShape2D
onready var animated_sprite: AnimatedSprite = $animatedSprite
var tween : SceneTreeTween

func _ready() -> void:
	Event.listen("player_death",self,"stop_tween")

func _on_area2D_body_entered(_body: Node) -> void:
	if not falling:
		falling = true
		tween = get_tree().create_tween()
		animated_sprite.play("dying")
		tween.tween_property(self,"position:y",position.y,0.5) # warning-ignore:return_value_discarded
		tween.tween_property(self,"global_position:y",global_position.y+300.0,2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)# warning-ignore:return_value_discarded
		tween.tween_callback(self,"disable_everything")# warning-ignore:return_value_discarded

func disable_everything() -> void:
	collision_shape_2d.disabled = true
	animated_sprite.visible = false
	
func stop_tween() -> void:
	pass
	#if GameManager.is_on_camera(self):
	#	if tween and tween.is_valid():
	#		tween.kill()
