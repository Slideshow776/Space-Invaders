class_name EnemyProjectile
extends Area2D

const MOVEMENT_SPEED := 400

var types: Array[CompressedTexture2D] = [
	preload("res://assets/projectiles/enemy_projectile_0.png"),
	preload("res://assets/projectiles/enemy_projectile_1.png"),
	preload("res://assets/projectiles/enemy_projectile_2.png"),
	preload("res://assets/projectiles/enemy_projectile_3.png"),
	preload("res://assets/projectiles/enemy_projectile_4.png"),
]

@onready var sprite_2d = %Sprite2D


func _ready():
	area_entered.connect(_on_area_entered)
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2(1.9, 0.1), 0.1)
	tween.tween_property(self, "scale", Vector2(0.8, 1.2), 0.25)
	%AudioStreamPlayer.pitch_scale = randf_range(0.9, 1.1)
	%AudioStreamPlayer.play()


func _process(delta):
	var out_of_bounds: bool = position.y >= get_viewport_rect().size.y + sprite_2d.texture.get_height() * sprite_2d.scale.y
	if out_of_bounds:
		queue_free()
	else:		
		position.y += MOVEMENT_SPEED * delta


func set_type(type: int):
	sprite_2d.texture = types[type]


func _on_area_entered(area_that_entered: Area2D):
	queue_free()
