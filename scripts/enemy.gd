class_name Enemy
extends Area2D

signal changed_direction
signal died
signal reached_bottom

const MAX_ROTATION_ANGLE = 0.2
const ROTATION_SPEED = 3.0

var fast_speed := 600.0
var slow_speed := 10.0

var max_shooting_frequency := 32.0
var min_shooting_frequency := 16.0

var speed := slow_speed
var steering_factor := 10.0
var velocity := Vector2.ZERO
var direction = Vector2(1.0, 0.0)
var is_paused := false

var is_slow_speed := false
var movement_duration_fast := 0.75
var movement_duration_slow := 0.04
var type: int = -1
var sprites_frame_0: Array[CompressedTexture2D] = [
	preload("res://assets/enemies/enemy_0_0.png"),
	preload("res://assets/enemies/enemy_1_0.png"),
	preload("res://assets/enemies/enemy_2_0.png"),
	preload("res://assets/enemies/enemy_3_0.png"),
	preload("res://assets/enemies/enemy_4_0.png"),
]
var sprites_frame_1: Array[CompressedTexture2D] = [
	preload("res://assets/enemies/enemy_0_1.png"),
	preload("res://assets/enemies/enemy_1_1.png"),
	preload("res://assets/enemies/enemy_2_1.png"),
	preload("res://assets/enemies/enemy_3_1.png"),
	preload("res://assets/enemies/enemy_4_1.png"),
]
var is_animation_frame_0 = true

@onready var sprite_2d = %Sprite2D
@onready var projectile_timer = %ProjectileTimer
@onready var movement_timer = %MovementTimer


func _ready():
	projectile_timer.set_wait_time(randf_range(min_shooting_frequency, max_shooting_frequency))
	projectile_timer.start(randf_range(0.0, projectile_timer.wait_time))
	projectile_timer.connect("timeout", _on_projectile_timer_timeout)
	
	movement_timer.connect("timeout", _on_movement_timer_timeout)
	
	area_entered.connect(_on_area_entered)
	

func _process(delta):
	if is_paused:
		return
	
	var direction := _handle_movement(delta)
	_rotate_into_direction(delta, direction)


func drop_down_one_level():
	var tween := create_tween()	
	var amount: float = sprite_2d.texture.get_height() * sprite_2d.scale.y
	tween.tween_property(self, "position:y", position.y + amount, 0.2)
	tween.parallel()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "scale", Vector2(0.8, 1.2), 0.2)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	
	if position.y + (2 * amount) >= get_viewport_rect().size.y:
		reached_bottom.emit()


func game_over():
	is_paused = true
	projectile_timer.stop()


func update_speed():
	fast_speed *= 1.02
	movement_duration_slow /= .99
	
	max_shooting_frequency *= .9
	min_shooting_frequency *= .9


func _handle_movement(delta: float) -> Vector2:
	var bounds := get_viewport_rect().size
	var width: float = sprite_2d.texture.get_width() * sprite_2d.scale.x
	if (position.x > bounds.x - width) and (direction.x > 0.0):
		_change_direction()
	elif (position.x < 0 + width) and (direction.x < 0.0):
		_change_direction()
	
	var desired_velocity: Vector2 = speed * direction
	var steering_vector := desired_velocity - velocity	
	velocity += steering_vector * steering_factor * delta
	position += velocity * delta
	
	return direction


func _change_direction():
	changed_direction.emit(self)
	direction.x *= -1
	drop_down_one_level()


func _rotate_into_direction(delta: float, direction: Vector2):
	if direction.x < 0:  # Moving left
		rotation = lerp(rotation, -MAX_ROTATION_ANGLE, ROTATION_SPEED * delta)
	elif direction.x > 0:  # Moving right
		rotation = lerp(rotation, MAX_ROTATION_ANGLE, ROTATION_SPEED * delta)
	else:  # No horizontal movement, return to upright position
		rotation = lerp(rotation, 0.0, ROTATION_SPEED * delta)

	
func _on_projectile_timer_timeout():
	projectile_timer.set_wait_time(randf_range(min_shooting_frequency, max_shooting_frequency))
	
	var tween := create_tween()		
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	var amount := 2 * PI
	if randf() < 0.5:
		amount *= -1	
	tween.tween_property(self, "rotation", amount, randf_range(0.4, 0.6))
	
	var projectile := preload("res://scenes/enemy_projectile.tscn").instantiate()
	projectile.position = global_position
	get_parent().add_child(projectile)
	projectile.set_type(type)
	

func _on_movement_timer_timeout():
	if is_slow_speed:
		is_slow_speed = false
		is_animation_frame_0 = !is_animation_frame_0
		if is_animation_frame_0:
			_set_animation_frame(0)
		else:
			_set_animation_frame(1)
		speed = fast_speed
		movement_timer.set_wait_time(movement_duration_fast)
		
		var tween := create_tween()
		tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
	else:
		is_slow_speed = true
		speed = slow_speed
		movement_timer.set_wait_time(movement_duration_slow)
		
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.05)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25)
	
	
func _on_area_entered(area_that_entered: Area2D):
	died.emit(self)
	projectile_timer.stop()
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite_2d, "scale", Vector2.ZERO, 0.25)
	tween.finished.connect(queue_free)
	
	%AudioStreamPlayer.pitch_scale = randf_range(0.9, 1.1)
	%AudioStreamPlayer.play()


func _set_animation_frame(frame_index: int):
	if frame_index == 0:
		sprite_2d.texture = sprites_frame_0[type]
	elif frame_index == 1:
		sprite_2d.texture = sprites_frame_1[type]
	else:
		printerr("Function was called with invalid frame index!")
