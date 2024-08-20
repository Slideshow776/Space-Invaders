class_name Ufo
extends Area2D

signal died

const MAX_ROTATION_ANGLE = 0.2
const ROTATION_SPEED = 3.0

const SINE_FREQUENCY = 7.5
const SINE_AMPLITUDE = 80.0

var max_speed := 200.0
var speed := max_speed
var steering_factor := 10.0
var velocity := Vector2.ZERO
var direction = Vector2(1.0, 0.0)

var is_dead := false
var is_restarting := false
var time_passed := 0.0
var original_y_position: float

@onready var sprite_2d = %Sprite2D
@onready var spawn_timer = %SpawnTimer
@onready var movement_sound = %MovementSound


func _ready():
	area_entered.connect(_on_area_entered)
	spawn_timer.connect("timeout", _on_spawn_timer_timeout)
	original_y_position = position.y
	movement_sound.play()


func _process(delta):
	var direction := _handle_movement(delta)
	if is_dead:
		return
	
	time_passed += delta
	
	_rotate_into_direction(delta, direction)
	_apply_sine_wave_movement(delta)


func _handle_movement(delta: float) -> Vector2:
	var bounds := get_viewport_rect().size
	var width: float = sprite_2d.texture.get_width() * sprite_2d.scale.x
	if (position.x > bounds.x + width) and direction.x > 0.0:
		_handle_outside_view()
	elif (position.x < 0 - width) and direction.x < 0.0:
		_handle_outside_view()
	
	var desired_velocity: Vector2 = speed * direction
	var steering_vector := desired_velocity - velocity	
	velocity += steering_vector * steering_factor * delta
	position += velocity * delta
	
	return direction


func _rotate_into_direction(delta: float, direction: Vector2):
	if direction.x < 0:  # Moving left
		rotation = lerp(rotation, -MAX_ROTATION_ANGLE, ROTATION_SPEED * delta)
	elif direction.x > 0:  # Moving right
		rotation = lerp(rotation, MAX_ROTATION_ANGLE, ROTATION_SPEED * delta)
	else:  # No horizontal movement, return to upright position
		rotation = lerp(rotation, 0.0, ROTATION_SPEED * delta)


func _handle_outside_view():
	if is_restarting or not spawn_timer.is_stopped():
		return
	
	is_restarting = true
	spawn_timer.set_wait_time(randf_range(7.5, 14.0))
	spawn_timer.start()
	movement_sound.stop()


func _on_spawn_timer_timeout():	
	is_restarting = false
	
	var bounds := get_viewport_rect().size
	var width: float = sprite_2d.texture.get_width() * sprite_2d.scale.x
	
	if randf() >= 0.5:
		position.x = bounds.x + width
	else:
		position.x = 0 - width
	
	if position.x < 0:
		direction.x = 1.0
	elif position.x > bounds.x:
		direction.x = -1.0
		
	is_dead = false
	speed = max_speed
	set_collision_layer(3)
	set_collision_mask(2)
	rotation = 0.0
	modulate.a = 1.0
	direction.y = 0.0
	position.y = original_y_position + 40
	movement_sound.play()


func _on_area_entered(area_that_entered: Area2D):
	is_dead = true
	died.emit(self)
	movement_sound.stop()
	spawn_timer.start()
	max_speed *= 1.1
	steering_factor = 10.0
	velocity = Vector2.ZERO

	time_passed = 0.0
	
	%DeathSound.play()
	#%DeathSound.finished.connect(queue_free)
	direction = Vector2(0.0, 1.0)
	speed = 10.0
	set_collision_layer(0)
	set_collision_mask(0)
	
	var tween := create_tween()
	tween.tween_property(self, "rotation", 5.0, 0.5)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)


func _apply_sine_wave_movement(delta: float):
	position.y += sin(time_passed * SINE_FREQUENCY) * SINE_AMPLITUDE * delta
