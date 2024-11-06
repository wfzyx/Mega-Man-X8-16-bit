extends X8TextureButton

var waiting_for_input = false
var original_event: InputEvent
var timer := 0.0
var old_text := ""
signal waiting
signal updated_event
onready var text: Label = $text
onready var actionname: Label = $"../actionname"

func _process(delta: float) -> void:
	if timer >= 0.01:
		timer += delta
		text.self_modulate.a = inverse_lerp(-1, 1, sin(timer * 6))
	if timer > 5:
		print_debug("waiting cancel")
		menu.emit_signal("unlock_buttons")
		grab_focus()
		waiting_for_input = false
		timer = 0
		set_text(old_text)
		text.self_modulate.a = 1.0

func _input(event: InputEvent) -> void:
	if not has_focus():
		return
	if event is InputEventMouseMotion:
		return
	elif timer > 0.25:
		if name == "key" and event is InputEventMouseButton and not event.is_pressed():
			#print_debug("Detected mouse press for " + get_parent().action)
			#print_debug(event.as_text())
			set_new_action_event(event)
		elif name == "key" and event is InputEventKey and not event.is_pressed():
			#print_debug("Detected key press for " + get_parent().action)
			#print_debug(event.as_text())
			set_new_action_event(event)
		elif name == "joypad" and event is InputEventJoypadButton and not event.is_pressed():
			#print_debug("Detected joybutton press for " + get_parent().action)
			#print_debug(event.as_text())
			set_new_action_event(event)
		elif name == "joypad" and event is InputEventJoypadMotion:
			if abs(event.axis_value) > 0.35:
				#print_debug("Detected joyaxis for " + get_parent().action)
				#print_debug(event.as_text())
				set_new_action_event(event)

func set_new_action_event(event) -> void:
	InputManager.set_new_action_event(get_parent().action, event, original_event)
	emit_signal("updated_event")
	waiting_for_input = false
	timer = 0
	text.self_modulate.a = 1.0
	menu.emit_signal("unlock_buttons")
	grab_focus()

func on_press() -> void:
	if timer == 0:
		.on_press()
		#action = $"..".action
		old_text = get_text()
		set_text("...")
		timer = 0.01
		emit_signal("waiting")
		menu.emit_signal("lock_buttons")
		focus_mode = Control.FOCUS_ALL
		grab_focus()

func set_text(txt) -> void:
	InputManager.emit_signal("double_check", txt, $"../actionname".text)
	text.text = txt

func get_text() -> String:
	 return text.text
