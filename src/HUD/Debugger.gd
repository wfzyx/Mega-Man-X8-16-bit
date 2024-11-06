extends Control

onready var character = get_tree().current_scene.find_node("X")

const bike = preload("res://src/Actors/Props/RideChaser.tscn")
const ridearmor = preload("res://src/Actors/Props/RideArmor/RideArmor.tscn")
const ridearmor2 = preload("res://src/Actors/Props/RideArmor/RideArmorNoCannon.tscn")
var last_checkpoint: Node2D
onready var checkpoints := get_parent().get_parent().get_parent().get_parent().get_node_or_null("Checkpoints")
var open := false
onready var main_button: Button = $vBoxContainer/hide_menu

onready var cheat_buttons: HBoxContainer = $vBoxContainer/hBoxContainer

signal cheat_pressed(visibility)

func _ready() -> void:
	
	hide_totally()
	show_cheats()
	
	close_cheats()
	Event.connect("pause_menu_opened", self, "close_cheats")
	Event.connect("pause_menu_opened", self, "hide_totally")
	Event.connect("pause_menu_closed", self, "show_cheats")
	Event.connect("boss_start", self, "on_boss_start")
	if checkpoints:
		if checkpoints.get_child_count() > 0:
			last_checkpoint = checkpoints.get_child(checkpoints.get_child_count() - 1)


func _physics_process(_delta: float) -> void:
	if visible:
		if Input.is_action_pressed("debug") and Input.is_action_pressed("debug2"):
			_on_reset_checkpoint_pressed()

func show_cheats():
	if GameManager.debug_enabled or OS.has_feature("editor"):
		if Configurations.get("ShowDebug"):
			visible = true

func hide_totally():
	visible = false

func stage_has_checkpoints() -> bool:
	return checkpoints.get_child_count() > 0

#func _input(event: InputEvent) -> void:
#	if open:
#		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
#			_on_hide_menu_pressed()
#			close_cheats()

func _on_hide_menu_pressed() -> void:
	open = !open
	GameManager.used_cheats = true
	for option in $vBoxContainer.get_children():
		if option.name != "hide_menu":
			option.set_visible(not option.is_visible())
	_on_pause_pressed()
	emit_signal("cheat_pressed", cheat_buttons.visible)

func close_cheats():
	open = false
	for option in $vBoxContainer.get_children():
		if option.name != "hide_menu":
			option.set_visible(false)
		else:
			option.pressed = false
	GameManager.unpause("DebugMenu")
	

func show_debug(show=true) -> void:
	$vBoxContainer.visible = show

func _on_icarus_head_pressed() -> void:
	Event.emit_signal("collected", "icarus_head")

func _on_icarus_body_pressed() -> void:
	Event.emit_signal("collected", "icarus_body")
	
func _on_icarus_arms_pressed() -> void:
	Event.emit_signal("collected", "icarus_arms")

func _on_icarus_legs_pressed() -> void:
	Event.emit_signal("collected", "icarus_legs")

func _on_hermes_head_pressed() -> void:
	Event.emit_signal("collected", "hermes_head")

func _on_hermes_body_pressed() -> void:
	Event.emit_signal("collected", "hermes_body")

func _on_hermes_arms_pressed() -> void:
	Event.emit_signal("collected", "hermes_arms")

func _on_hermes_legs_pressed() -> void:
	Event.emit_signal("collected", "hermes_legs")

func _on_damage_pressed() -> void:
	character.invulnerability = 0.0
	character.damage(2)

func _on_heal_pressed() -> void:
	character.current_health = character.max_health

func _on_inifinte_health_pressed() -> void:
	character.current_health = 16000

func _on_disable_camera_limits_pressed() -> void:
	GameManager.camera.set_limits(-100000, 100000, -100000, 100000)

func _on_reset_stage_pressed() -> void:
	GameManager.checkpoint = null
	GlobalVariables.set("pitch_black_energized", false)
	GameManager.restart_level()

func _on_remove_collects_pressed() -> void:
	GameManager.collectibles = []
	#GlobalVariables.erase("vile3_defeated")
	#GlobalVariables.erase("gateway_bosses_beaten")
	#GlobalVariables.erase("copy_sigma_defeated")
	#GlobalVariables.erase("vile_palace_defeated")
	#GlobalVariables.erase("defeated_antonion_vile")
	#GlobalVariables.erase("defeated_panda_vile")
	
	GameManager.restart_level()
	pass # Replace with function body.

func _on_kill_pressed() -> void:
	character.current_health = 0


func _on_30fps_pressed() -> void:
	set_fps(30)


func _on_60fps_pressed() -> void:
	set_fps(60)


func _on_120fps_pressed() -> void:
	set_fps(120)


func _on_144fps_pressed() -> void:
	set_fps(144)

func set_fps(value: int) -> void:
	#if Engine.get_iterations_per_second() != value:
	print_debug("Engine fps: " + str(Engine.get_iterations_per_second()) + " changing to: " + str(value))
	Engine.iterations_per_second = value
	Engine.target_fps = value
	$"vBoxContainer/hBoxContainer/vBoxContainer/144fps/fps".text = "fps: " + str(Engine.get_iterations_per_second()) + "target: " + str(Engine.target_fps)

func _on_pause_pressed() -> void:
	if cheat_buttons.visible:
		GameManager.pause("DebugMenu")
	else:
		GameManager.unpause("DebugMenu")

func _on_start_boss_pressed() -> void:
	GameManager.start_boss()


func _on_time_attack_pressed() -> void:
	$"../Rec Info".set_visible(not $"../Rec Info".is_visible())
	GameManager.time_attack = not GameManager.time_attack
	GameManager.restart_level()
	pass # Replace with function body.


func _on_1xSize_pressed() -> void:
	OS.set_window_size(Vector2(398, 224))


func _on_2xSize_pressed() -> void:
	OS.set_window_size(Vector2(796, 448))

func _on_3xSize_pressed() -> void:
	OS.set_window_size(Vector2(1194, 672))
	
func _on_fullscreen_pressed() -> void:
	OS.window_fullscreen = !OS.window_fullscreen

func _on_next_checkpoint_pressed() -> void:
	if not stage_has_checkpoints():
		return
	var current_c: int = 0
	if GameManager.checkpoint:
		current_c = GameManager.checkpoint.id
	var next_checkpoint = checkpoints.get_node(str(clamp(current_c + 1, 0, int(last_checkpoint.name))))
	GameManager.set_checkpoint(next_checkpoint.settings)
	GameManager.restart_level()

func _on_reset_checkpoint_pressed() -> void:
	GameManager.restart_level()

func _on_previous_checkpoint_pressed() -> void:
	if not stage_has_checkpoints():
		return
	var current_c: int = 0
	if GameManager.checkpoint:
		current_c = GameManager.checkpoint.id
	if current_c <= 1:
		_on_reset_stage_pressed()
	else:
		var previous_checkpoint = checkpoints.get_node(str(clamp(current_c - 1, 1, int(last_checkpoint.name))))
		GameManager.set_checkpoint(previous_checkpoint.settings)
		GameManager.restart_level()
	
func _on_teleport_to_boss_pressed() -> void:
	if not stage_has_checkpoints():
		return
	if last_checkpoint:
		GameManager.fill_subtanks()
		GameManager.reached_checkpoint(last_checkpoint.settings)
		GameManager.restart_level()


func _on_spawn_bike_pressed() -> void:
	var instance = bike.instance()
	get_tree().current_scene.add_child(instance, true)
	instance.set_position(GameManager.get_player_position())


func _on_mute_music_pressed() -> void:
	AudioServer.set_bus_mute(2, !AudioServer.is_bus_mute(2))


func _on_intro_stage_pressed() -> void:
	GameManager.start_level("NoahsPark")

func _on_show_colliders_pressed() -> void:
	get_tree().set_debug_collisions_hint(!get_tree().is_debugging_collisions_hint())

func _on_subtank1_pressed() -> void:
	for subtank in GameManager.player.get_node("Subtanks").get_children():
		if not subtank.active:
			GameManager.player.equip_subtank(subtank.subtank.id)
			GameManager.add_collectible_to_savedata(subtank.subtank.id)
			GlobalVariables.set(subtank.subtank.id, 0)
			break


func _on_use_subtank_pressed() -> void:
	Event.emit_signal("use_any_subtank")
	pass # Replace with function body.


func _on_unlock_weapons_pressed() -> void:
	GameManager.add_collectible_to_savedata("yeti_weapon")
	GameManager.add_collectible_to_savedata("rooster_weapon")
	GameManager.add_collectible_to_savedata("mantis_weapon")
	GameManager.add_collectible_to_savedata("sunflower_weapon")
	GameManager.add_collectible_to_savedata("trilobyte_weapon")
	GameManager.add_collectible_to_savedata("panda_weapon")
	GameManager.add_collectible_to_savedata("manowar_weapon")
	GameManager.add_collectible_to_savedata("antonion_weapon")
	GameManager.restart_level()
	pass # Replace with function body.


func _on_spawn_ridearm_pressed() -> void:
	var instance = ridearmor.instance()
	get_tree().current_scene.add_child(instance, true)
	var armor_pos = GameManager.get_player_position()
	armor_pos.y -= 16
	instance.set_position(armor_pos)


func _on_stage_select_pressed() -> void:
	GameManager.go_to_stage_select()


func _on_fill_subtank_pressed() -> void:
	GameManager.fill_subtanks()

const all_hearts = ["life_up_panda", "life_up_yeti", "life_up_manowar", "life_up_rooster", "life_up_trilobyte", "life_up_mantis", "life_up_antonion", "life_up_sunflower"]

func _on_add_heart_pressed() -> void:
	for heart in all_hearts:
		add_heart(heart)

func add_heart(collectible_name) -> void:
	if not GameManager.is_collectible_in_savedata(collectible_name):
		GameManager.player.max_health += 2
		GameManager.player.recover_health(2)
		GameManager.add_collectible_to_savedata(collectible_name)

func _on_remove_all_hearts() -> void:
	for heart in all_hearts:
		remove_heart(heart)

func remove_heart(collectible_name) -> void:
	if GameManager.is_collectible_in_savedata(collectible_name):
		GameManager.player.max_health -= 2
		if GameManager.player.current_health > 2:
			GameManager.player.reduce_health(2)
		GameManager.remove_collectible_from_savedata(collectible_name)

var bosses: Array
func on_boss_start(boss):
	bosses.append(boss)

func _on_defeat_boss_pressed() -> void:
	for boss in bosses:
		if is_instance_valid(boss):
			boss.current_health = 0
			_on_hide_menu_pressed()
			main_button.pressed = false


func _on_seraph_lumine_pressed() -> void:
	GameManager.go_to_lumine_boss_test()
	pass # Replace with function body.


func _on_rooster_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get", "rooster")
func _on_manow_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get", "manowar")
func _on_trilo_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get", "trilobyte")
func _on_sunf_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get", "sunflower")
func _on_yeti_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get", "yeti")
func _on_panda_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get", "panda")
func _on_mantis_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get", "mantis")

func _on_anton_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get", "antonion")
	pass # Replace with function body.


func _on_gateway_reset_pressed() -> void:
	GatewayManager.reset_bosses()
	_on_reset_stage_pressed()
	pass # Replace with function body.


func _on_gateway_final_pressed() -> void:
	Event.emit_signal("gateway_final_section")


func _on_sss_rank_pressed() -> void:
	GlobalVariables.set("RankSSS", true)
	pass # Replace with function body.


func _on_set_seed_text_entered(new_text: String) -> void:
	if new_text.is_valid_integer():
		BossRNG.set_seed(int(new_text))
		GameManager.restart_level()
	else:
		pass
	pass # Replace with function body.


func _on_gateway_pressed() -> void:
	GameManager.start_level("Gateway")
	pass # Replace with function body.


func _on_igtscreen_pressed() -> void:
	GameManager.go_to_igt()
	pass # Replace with function body.


func _on_spawn_gridearm_pressed() -> void:
	var instance = ridearmor2.instance()
	get_tree().current_scene.add_child(instance, true)
	var armor_pos = GameManager.get_player_position()
	armor_pos.y -= 16
	instance.current_health = instance.current_health / 2
	instance.set_position(armor_pos)
	pass # Replace with function body.
