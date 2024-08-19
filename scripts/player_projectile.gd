class_name PlayerProjectile
extends Area2D

const MOVEMENT_SPEED := 400

@onready var sprite_2d = %Sprite2D


func _ready():
	area_entered.connect(_on_area_entered)
	
	scale = Vector2(1.5, 0.5)
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BOUNCE)
	#tween.tween_property(self, "scale", Vector2(1.5, 0.5), 0.25)
	tween.tween_property(self, "scale", Vector2(0.7, 1.3), 0.5)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)
	tween.tween_property(self, "scale", Vector2(0.7, 1.3), 0.5)


func _process(delta):
	var out_of_bounds: bool = position.y <= -sprite_2d.texture.get_height() * sprite_2d.scale.y
	if out_of_bounds:	
		queue_free()
	else:		
		position.y -= MOVEMENT_SPEED * delta


func _on_area_entered(area_that_entered: Area2D):
	queue_free()
