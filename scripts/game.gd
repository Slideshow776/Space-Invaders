extends Node2D

const ENEMY_COUNT_X = 11
const ENEMY_COUNT_Y = 5

@onready var player = %Player

var enemies: Array[Enemy]


func _ready():
	_spawn_enemies()
	player.connect("died", _set_game_over)


func _input(event):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _spawn_enemies():
	var enemy_scene = preload("res://scenes/enemy.tscn")
	var example_enemy = enemy_scene.instantiate()
	var sprite_size = example_enemy.get_node("Sprite2D").texture.get_size() * example_enemy.get_node("Sprite2D").scale.x
	var spacing_x = sprite_size.x * 0.8
	var spacing_y = sprite_size.y * 1.0
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
			enemy.connect("changed_direction", _on_enemy_changed_direction)
			enemy.connect("died", _update_enemies)
			enemy.connect("reached_bottom", _set_game_over)
			enemy.position = Vector2(
				offset_x + x * spacing_x,
				offset_y + y * spacing_y
			)
			add_child(enemy)
			enemy.sprite_2d.texture = enemy.sprites[y % enemy.sprites.size()]


func _on_enemy_changed_direction(changed_enemy: Enemy):
	for enemy in enemies:
		if enemy != changed_enemy:
			enemy.direction.x *= -1
			enemy.drop_down_one_level()


func _update_enemies(dead_enemy: Enemy):
	enemies.erase(dead_enemy)
	for enemy in enemies:
		enemy.update_speed()
	if enemies.is_empty():
		_set_game_over("A   W I N N E R   I S   Y O U !")


func _set_game_over(message: String = "G A M E   O V E R !"):
	print(message)
	for enemy in enemies:
		enemy.game_over()
