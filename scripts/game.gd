extends Node2D

const ENEMY_COUNT_X = 5
const ENEMY_COUNT_Y = 2

var enemies: Array[Enemy]


func _ready():
	_spawn_enemies()


func _input(event):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _spawn_enemies():
	var enemy_scene = preload("res://scenes/enemy.tscn")
	var example_enemy = enemy_scene.instantiate()
	var sprite_size = example_enemy.get_node("Sprite2D").texture.get_size()
	var spacing_x = sprite_size.x * 0.5
	var spacing_y = sprite_size.y * 0.575
	example_enemy.queue_free()

	# Calculate the total width of the grid
	var grid_width = (ENEMY_COUNT_X - 1) * spacing_x + sprite_size.x
	
	# Calculate the offset to center the grid horizontally on the screen
	var screen_width = get_viewport().size.x
	var offset_x = (screen_width - grid_width) / 2 + (sprite_size.x * 0.55 * 0.7)  # Adjust for the first enemy width
	var offset_y = 30.0

	# Spawn the enemies in the grid
	for y in range(ENEMY_COUNT_Y):
		for x in range(ENEMY_COUNT_X):
			var enemy = enemy_scene.instantiate()
			enemies.append(enemy)
			enemy.connect("has_changed_direction", _on_enemy_changed_direction)
			enemy.position = Vector2(
				offset_x + x * spacing_x,
				offset_y + y * spacing_y
			)
			add_child(enemy)

func _on_enemy_changed_direction(enemy: Enemy):
	for enemy2 in enemies:
		if enemy == enemy2:
			continue
		enemy2.direction.x *= -1
