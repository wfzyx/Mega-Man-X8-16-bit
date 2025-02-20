extends HitDetector
class_name EnemyShield

export var breakable := true
var deflected = []

var debug_count := 0

signal activated
signal guard_broken(projectile)
signal shield_hit(projectile)
signal deactivated

func _ready() -> void:
	set_shield_as_self()
	if active:
		activate()

func set_shield_as_self():
	if "shield" in character:
		character.shield = self

func activate() -> void:
	set_shield_as_self()
	active = true
	call_deferred("toggle_disabled",false)
	emit_signal("activated")

func deactivate() -> void:
	active = false
	call_deferred("toggle_disabled",true)
	emit_signal("deactivated")

func toggle_disabled(value) -> void:
	$hittable_area/collisionShape2D.disabled = value

func is_visible() -> bool:
	return GameManager.is_on_screen(global_position)

func should_react() -> bool:
	return is_visible()

func react(_body: Node) -> void:
	for projectile in colliding_projectiles:
		if "has_deflectable" in projectile and projectile.has_deflectable:
			if not "Laser" in projectile.name:
				Log("Deflectable detected in " + projectile.name)
				continue
		if not projectile.get_instance_id() in deflected:
			Log("Deflecting projectile: " + projectile.name)
			if projectile.is_in_group("Props"):
				Log("Guard Break by bike") 
				call_deferred("emit_guard_break")
				return
			deflect_projectile(projectile)

func deflect_projectile(projectile) -> void:
	Log("Deflecting projectile: " + projectile.name)
	projectile.deflect(self)
	hit_sound.play()
	deflected.append(projectile.get_instance_id())
	#handle_damage_over_time(projectile)
	handle_break_guard(projectile)

func handle_damage_over_time(projectile) -> void:
	if "continuous_damage" in projectile and projectile.continuous_damage:
		if character is Actor:
			projectile.hit(character)
		else:
			push_error("Trying to hit a not actor, error imminent")

func handle_break_guard(projectile) -> void:
	if projectile.break_guards:
		Log("Guard Break by shot")
		call_deferred("emit_guard_break",projectile)
	else:
		emit("shield_hit")
	emit_signal("shield_hit",projectile)

func on_direct_hit(damagevalue :DamageValue) -> DamageValue:
	if active:
		Log("Deflecting direct hit: " + damagevalue.name)
		damagevalue.deflect(self)
		hit_sound.play()
		handle_damage_over_time(damagevalue)
		handle_break_guard(damagevalue)
	return damagevalue

func _physics_process(_delta: float) -> void:
	if character is Actor:
		hittable_area.scale.x = character.get_direction()

func emit_guard_break(projectile) -> void:
	if breakable:
		emit("guard_break")
		emit_signal("guard_broken",projectile)
	else:
		emit("shield_hit")
		
	colliding_projectiles.clear()

func emit(signal_name) -> void:
	if character.has_signal(signal_name):
		character.emit_signal(signal_name)
	
