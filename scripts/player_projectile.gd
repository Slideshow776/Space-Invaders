class_name PlayerProjectile
extends Area2D

const MOVEMENT_SPEED := 400

@onready var sprite_2d = %Sprite2D


func _process(delta):
	var out_of_bounds: bool = position.y <= -sprite_2d.texture.get_height() * sprite_2d.scale.y
	if out_of_bounds:	
		queue_free()
	else:		
		position.y -= MOVEMENT_SPEED * delta
