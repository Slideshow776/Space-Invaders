extends Area2D

signal died

const MAX_SPEED := 500.0
const MAX_ROTATION_ANGLE = 0.2
const ROTATION_SPEED = 3.0

var steering_factor := 10.0
var velocity := Vector2.ZERO

@onready var projectile_timer = %ProjectileTimer


func _ready():	
	area_entered.connect(_on_area_entered)


func _process(delta):	
	var direction := _poll_movement(delta)
	_rotate_into_direction(delta, direction)
	

func _input(event):
	if Input.is_action_just_pressed("shoot"):
		_shoot()
	
	
func _poll_movement(delta: float) -> Vector2:
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	
	var desired_velocity: Vector2 = MAX_SPEED * direction
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


func _shoot():	
	if not projectile_timer.is_stopped():
		return
		
	projectile_timer.start()
	
	var projectile := preload("res://scenes/player_projectile.tscn").instantiate()
	projectile.position = global_position
	get_parent().add_child(projectile)


func _on_area_entered(area_that_entered: Area2D):
	died.emit()
	queue_free()
