class_name EnemyProjectile
extends Area2D

const MOVEMENT_SPEED := 400

@onready var sprite_2d = %Sprite2D


func _ready():
	area_entered.connect(_on_area_entered)


func _process(delta):
	var out_of_bounds: bool = position.y >= get_viewport_rect().size.y + sprite_2d.texture.get_height() * sprite_2d.scale.y
	if out_of_bounds:
		queue_free()
	else:		
		position.y += MOVEMENT_SPEED * delta


func _on_area_entered(area_that_entered: Area2D):
	queue_free()
