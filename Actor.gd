extends KinematicBody2D
class_name Actor

export var debug_logs := false
export var active := true
export var max_health := 32.0
onready var current_health := max_health
onready var animatedSprite := get_node("animatedSprite")

var conveyor_belt_speed = 0.0

const gravity = 900.0
const maximum_fall_velocity := 375.0
const up_direction := Vector2.UP
const snap_direction := Vector2.DOWN
const snap_length := 8.0
var snap_vector := snap_direction * snap_length
var velocity = Vector2.ZERO
var bonus_velocity = Vector2.ZERO
var final_velocity = Vector2.ZERO
var direction := Vector2.ZERO
var time_since_on_floor := 0.0
var moved_since_last_frame := Vector2.ZERO
var facing_right := true
var invulnerability: float
var toggleable_invulnerabilities = []
var emitted_zero_health := false


var last_message

signal damage(value, inflicter)
signal zero_health
 
signal death
signal new_direction(dir)

func get_conveyor_belt_speed() -> float:
	return conveyor_belt_speed

func add_conveyor_belt_speed(conveyor_speed: float):
	conveyor_belt_speed += conveyor_speed

func reduce_conveyor_belt_speed(conveyor_speed: float):
	conveyor_belt_speed -= conveyor_speed

func _ready() -> void:
	set_safe_margin(0.01)

func _physics_process(delta: float) -> void:
	process_invulnerability(delta)
	process_movement()
	process_zero_health()
	
func update_facing_direction():
	if animatedSprite.visible:
		if direction.x < 0:
			facing_right = false;
		elif direction.x >= 0:
			facing_right = true;
		if animatedSprite.scale.x != get_facing_direction():
			animatedSprite.scale.x = get_facing_direction()

func process_movement():
	if animatedSprite.visible:
		final_velocity = velocity + bonus_velocity
										# warning-ignore:return_value_discarded
		move_and_collide(Vector2.ZERO) # Bandaid for being pushed bug
		final_velocity = process_final_velocity()
		velocity.y = final_velocity.y

func process_zero_health():
	if not has_health() and not emitted_zero_health:
		emit_zero_health_signal()

func process_final_velocity() -> Vector2:
	return move_and_slide_with_snap(final_velocity, snap_vector, up_direction, true, 4, 0.8)

func damage(value, inflicter=null) -> float:
	if not is_invulnerable():
		emit_signal("damage", value, inflicter)
	return current_health

func reduce_health(value: float):
	current_health -= value
	
func recover_health(value: float):
	if current_health < max_health:
		current_health += value

func is_invulnerable() -> bool:
	return invulnerability > 0.0 or toggleable_invulnerabilities.size() > 0

func add_invulnerability(ability_name):
	toggleable_invulnerabilities.append(ability_name)

func remove_invulnerability(ability_name):
	toggleable_invulnerabilities.erase(ability_name)

func set_invulnerability(time: float):
	if time > 0:
		invulnerability = time

func process_invulnerability(delta):
	if invulnerability > 0:
		invulnerability -= delta

func is_max_health() -> bool:
	return current_health >= max_health
	
func has_health() -> bool:
	return current_health > 0

func is_low_health() -> bool:
	return current_health - 1 < max_health / 4

func emit_zero_health_signal():
	if not emitted_zero_health:
		emit_signal("zero_health")
		emitted_zero_health = true

func has_just_been_on_floor(leeway: float) -> bool:
	if is_on_floor():
		return true
	else:
		if time_since_on_floor < leeway:
			return true
	
	return false

func get_actual_horizontal_speed() -> float:
	return final_velocity.x

func set_horizontal_speed(speed: float):
	velocity.x = speed

func add_horizontal_speed(speed: float):
	velocity.x = velocity.x + speed

func set_bonus_horizontal_speed(speed: float):
	bonus_velocity.x = speed
	
func get_bonus_horizontal_speed() -> float:
	return bonus_velocity.x
	
func get_horizontal_speed() -> float:
	return velocity.x

func get_vertical_speed() -> float:
	return velocity.y
func get_actual_vertical_speed() -> float:
	return final_velocity.y
	
func add_vertical_speed(speed: float):
	velocity.y = velocity.y + speed

func set_vertical_speed(speed: float, floor_snap:=true):
	if speed == 0 and floor_snap:
		enable_floor_snap()
	else:
		disable_floor_snap()
	velocity.y = speed

func enable_floor_snap():
	if snap_vector != snap_direction * snap_length:
		snap_vector = snap_direction * snap_length

func reduce_floor_snap(snap:=1.0):
	if snap_vector != snap_direction * snap:
		snap_vector = snap_direction * snap
		
func disable_floor_snap():
	if snap_vector != Vector2.ZERO:
		snap_vector = Vector2.ZERO

func is_snapped_to_floor() -> bool:
	return snap_vector != Vector2.ZERO

func spawner_set_direction(dir: int, _update:=false) -> void:
	#print("SPAWNER SET DIR FOR " + name + " " + str(dir)+ " " + str(update))
	set_direction(dir, true)
	#Tools.timer_p(0.05,"set_direction",self,[dir,update])

func set_direction(dir: int, update:=false):
	direction.x = dir
	emit_signal("new_direction", dir)
	if update:
		update_facing_direction()

func get_facing_direction():
	return n_int(facing_right)

func get_direction() -> float:
	return direction.x

func n_int(_direction: bool) -> int:
	if not _direction:
		return -1;
	return 1;

func stop_all_movement():
	velocity = Vector2.ZERO
	bonus_velocity = Vector2.ZERO
	final_velocity = Vector2.ZERO
	disable_floor_snap()

func destroy() -> void:
	queue_free()

func listen(event_name: String, listener, method_to_call: String):
	var error_code = connect(event_name, listener, method_to_call)
	if error_code != 0:
		print_debug(name + ".listen: Connection error. Code: " + str(error_code))
		print_debug(listener.name + "'s method " + method_to_call + " on event " + event_name)

func Log(msg) -> void:
	if debug_logs:
		if not last_message == str(msg):
			print_debug(get_parent().name + "." + name + ": " + str(msg))
			last_message = str(msg)
