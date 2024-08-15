class_name Enemy
extends Area2D

signal changed_direction
signal died
signal reached_bottom

const MAX_ROTATION_ANGLE = 0.2
const ROTATION_SPEED = 3.0
const SLOW_SPEED = 10.0
const FAST_SPEED = 600.0

var speed := SLOW_SPEED
var steering_factor := 10.0
var velocity := Vector2.ZERO
var direction = Vector2(1.0, 0.0)
var is_paused := false

@onready var projectile_timer = %ProjectileTimer
@onready var movement_timer = %MovementTimer
@onready var sprite_2d = %Sprite2D


func _ready():
	#projectile_timer.connect("timeout", _on_projectile_timer_timeout)
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
	
	if position.y + (2 * amount) >= get_viewport_rect().size.y:
		reached_bottom.emit()


func _handle_movement(delta: float) -> Vector2:
	var bounds := get_viewport_rect().size
	var size: float = sprite_2d.texture.get_width() * sprite_2d.scale.x
	if position.x > bounds.x - size and direction.x > 0.0:
		_change_direction()
	elif position.x < 0 + size and direction.x < 0.0:
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

	
#func _on_projectile_timer_timeout():
	#var projectile := preload("res://scenes/enemy_projectile.tscn").instantiate()
	#projectile.position = global_position
	#get_parent().add_child(projectile)
	

func _on_movement_timer_timeout():
	if speed == SLOW_SPEED:
		speed = FAST_SPEED
		movement_timer.wait_time = 0.75
	elif speed == FAST_SPEED:
		speed = SLOW_SPEED	 
		movement_timer.wait_time = 0.04
	
	
func _on_area_entered(area_that_entered: Area2D):
	died.emit(self)
	queue_free()
