extends Area2D

const MAX_HEALTH := 3

var health = MAX_HEALTH


func _ready():
	area_entered.connect(_on_area_entered)


func _on_area_entered(area_entered: Area2D):
	health -= 1
	if health <= 0:
		queue_free()
		
