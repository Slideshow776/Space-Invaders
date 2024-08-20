extends Camera2D

var random_strength := 2.5
var shake_fade := 5.0
var rng = RandomNumberGenerator.new()
var shake_strength := 0.0
var is_start := false
var rotation_strength := 0.01


func _ready():
	set_ignore_rotation(false)


func _process(delta):
	if is_start:
		apply_shake()
		is_start = false
		
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		offset = random_offset()
		rotation = random_rotation()


func start_shake(position_strength: float = random_strength, rotation_strength: float = rotation_strength):
	random_strength = position_strength
	self.rotation_strength = rotation_strength
	if not is_start:
		is_start = true


func apply_shake():
	shake_strength = random_strength
	

func random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)


func random_rotation() -> float:
	return rng.randf_range(
		-rotation_strength * shake_strength,
		 rotation_strength * shake_strength
	)
