class_name Player
extends Area2D

signal died

const MAX_SPEED := 500.0
const MAX_ROTATION_ANGLE = 0.2
const ROTATION_SPEED = 3.0

var steering_factor := 10.0
var velocity := Vector2.ZERO
var is_dead := false

@onready var projectile_timer = %ProjectileTimer
@onready var animated_sprite_2d = %AnimatedSprite2D
@onready var original_scale: Vector2 = animated_sprite_2d.scale


func _ready():
	area_entered.connect(_on_area_entered)
	animated_sprite_2d.play("default")


func _process(delta):
	var direction := _poll_movement(delta)
	_rotate_into_direction(delta, direction)
	_wrap_position()
	#_stretchAndSqueeze()
	
	if Input.is_action_pressed("shoot") and not is_dead:
		_shoot()
	

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


func _wrap_position():
	var temp = animated_sprite_2d.sprite_frames.get_frame_texture(animated_sprite_2d.animation, animated_sprite_2d.frame).get_size().x
	var width: float = temp * animated_sprite_2d.scale.x
	if position.x + width <= 0:
		position.x = get_viewport_rect().size.x
	elif position.x >= get_viewport_rect().size.x + width:
		position.x = 0


func _shoot():
	if not projectile_timer.is_stopped():
		return
		
	projectile_timer.start()
	
	var projectile := preload("res://scenes/player_projectile.tscn").instantiate()
	projectile.position = global_position
	get_parent().add_child(projectile)
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	var amount := Vector2(original_scale.x * 1.2, original_scale.y * 0.8)
	tween.tween_property(animated_sprite_2d, "scale", amount, 0.167)
	amount = Vector2(original_scale.x * 0.8, original_scale.y * 1.2)
	tween.tween_property(animated_sprite_2d, "scale", amount, 0.167)
	tween.tween_property(animated_sprite_2d, "scale", original_scale, 0.167)


func _on_area_entered(area_that_entered: Area2D):
	%AudioStreamPlayer.play()
	%AudioStreamPlayer.finished.connect(queue_free)
	
	self.set_collision_layer(0)
	self.set_collision_mask(0)
	died.emit()
	is_dead = true
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(animated_sprite_2d, "scale", Vector2.ZERO, 0.25)


func _stretchAndSqueeze():
	if velocity.length() > MAX_SPEED * 0.9:
		# Player is moving: Stretch
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_LINEAR)
		var amount := Vector2(original_scale.x * 1.1, original_scale.y * 0.9)
		tween.tween_property(animated_sprite_2d, "scale", amount, 0.2)
	elif scale != original_scale:
		# Player is not moving: Squeeze back to normal
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(animated_sprite_2d, "scale", original_scale, 0.2)

