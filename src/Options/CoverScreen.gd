extends ColorRect
export var menu : NodePath
export var background : NodePath
onready var main = get_node(menu)
var bg

export var duration := 0.25
var transitioning := false
var tween : SceneTreeTween

signal finished

func _ready() -> void:
	if background:
		bg = get_node(background)

func FadeIn() -> void:
	transitioning = true
	reset_tween()
	tween.tween_property(self,"color",Color.black,duration)    # warning-ignore:return_value_discarded
	tween.tween_callback(self,"show_menu")                    # warning-ignore:return_value_discarded
	tween.tween_property(self,"color",Color(0,0,0,0),duration) # warning-ignore:return_value_discarded
	tween.tween_callback(self,"finish")                        # warning-ignore:return_value_discarded
	
func FadeOut() -> void:
	transitioning = true
	reset_tween()
	tween.tween_property(self,"color",Color.black,duration)    # warning-ignore:return_value_discarded
	tween.tween_callback(self,"hide_menu")                    # warning-ignore:return_value_discarded
	tween.tween_property(self,"color",Color(0,0,0,0),duration) # warning-ignore:return_value_discarded
	tween.tween_callback(self,"finish")                        # warning-ignore:return_value_discarded

func SoftFadeOut() -> void:
	transitioning = true
	reset_tween()
	tween.tween_property(self,"color",Color.black,duration * 4) # warning-ignore:return_value_discarded
	tween.tween_property(self,"color",Color.black,duration * 4)   # warning-ignore:return_value_discarded
	tween.tween_callback(self,"finish")   # warning-ignore:return_value_discarded
	

func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()

func show_menu() -> void:
	main.set_visible(true)
	if bg:
		bg.set_visible(true)

func hide_menu() -> void:
	main.set_visible(false)
	if bg:
		bg.set_visible(false)

func finish() -> void:
	emit_signal("finished")
	transitioning = false
	
