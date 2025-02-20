extends NinePatchRect

var weapon
onready var weapon_icon: TextureRect = $"../WeaponIcon"
onready var ammo_bar: TextureProgress = $textureProgress

signal displayed(weapon)
signal hidden

func display(current_weapon) -> void:
	if is_exception(current_weapon):
		weapon = null
		hide()
		return
	weapon = current_weapon
	var icon = weapon.weapon.icon
	var palette = weapon.weapon.palette
	weapon_icon.texture.atlas = icon
	ammo_bar.material.set_shader_param("palette", palette)
	ammo_bar.value = get_bar_value()
	show() 
	emit_signal("displayed",current_weapon)

func is_exception(current_weapon) -> bool:
	if "Buster" in current_weapon.name:
		return true
	#if "XDrive" in current_weapon.name:
	#	return true
	return false

func _process(_delta: float) -> void:
	if weapon:
		ammo_bar.value = get_bar_value()
		if weapon.current_ammo > 0 and weapon.current_ammo< 1:
			ammo_bar.value = 1

func get_bar_value() -> float:
	return inverse_lerp(0.0,weapon.max_ammo,weapon.current_ammo) * 28

func _ready() -> void:
	Event.listen("changed_weapon",self,"display")
	hide()

func hide() -> void:
	weapon_icon.visible = false
	visible = false
	emit_signal("hidden")

func show() -> void:
	weapon_icon.visible = true
	visible = true
