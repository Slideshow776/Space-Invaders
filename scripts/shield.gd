extends Area2D

const MAX_HEALTH := 3

var health = MAX_HEALTH


func _ready():
	area_entered.connect(_on_area_entered)


func _on_area_entered(area_entered: Area2D):
	health -= 1
	if health <= 0:
		queue_free()
	
	_bounce_animation()
	

func _bounce_animation():	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2(1.1, 0.9), 0.1)
	tween.tween_property(self, "scale", Vector2(0.95, 1.05), 2.0)
	tween.tween_property(self, "scale", Vector2.ONE, 1.5)
