extends Node2D

const ENEMY_COUNT_X = 11
const ENEMY_COUNT_Y = 5

@onready var player = %Player
@onready var camera_2d = %Camera2D
@onready var hitstop_timer = $HitstopTimer
@onready var score_label = %ScoreLabel
@onready var message_label = %MessageLabel

var enemies: Array[Enemy]
var is_shakeable := true
var score := 0


func _ready():
	_spawn_enemies()
	_spawn_ufo()
	
	player.connect("died", _set_game_over)
	hitstop_timer.connect("timeout", _resume_game.bind())


func _input(event):
	if Input.is_action_just_pressed("restart"):
		_restart()
	elif Input.is_action_just_pressed("toggle_shake"):
		is_shakeable = !is_shakeable


func _restart():	
	Engine.time_scale = 1.0
	Music.play(0.0)
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
			enemy.type = y % enemy.sprites_frame_0.size()


func _spawn_ufo():
	var ufo := preload("res://scenes/ufo.tscn").instantiate()
	ufo.connect("died", _add_score.bind(1000))
	ufo.position = Vector2(2000.0, 100.0)
	add_child(ufo)
	ufo.spawn_timer.set_wait_time(30.0)


func _on_enemy_changed_direction(changed_enemy: Enemy):
	for enemy in enemies:
		if enemy != changed_enemy:
			enemy.direction.x *= -1
			enemy.drop_down_one_level()


func _update_enemies(dead_enemy: Enemy):
	if is_shakeable:
		camera_2d.start_shake()
	
	hitstop_timer.start()
	_add_score(100)
	_pause_game()
	
	enemies.erase(dead_enemy)
	for enemy in enemies:
		enemy.update_speed()
	if enemies.is_empty():
		_set_game_over("A   W I N N E R   I S   Y O U !")


func _add_score(temp: int):
	score += temp
	score_label.text = str(score)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(score_label, "scale", Vector2(0.8, 1.2), 0.1)
	tween.tween_property(score_label, "scale", Vector2(1.1, 0.9), 0.1)
	tween.tween_property(score_label, "scale", Vector2.ONE, 0.1)


func _set_game_over(message: String = "G A M E   O V E R !"):
	if message == "G A M E   O V E R !":
		Engine.time_scale = 0.5
	message_label.text = message
	message_label.z_index = 1110
	message_label.visible = true
	camera_2d.start_shake(5.0, 0.02)
	hitstop_timer.wait_time = 0.5
	hitstop_timer.start()
	_pause_game()
	
	for enemy in enemies:
		enemy.game_over()
		
	for child in get_children():
		if child is Ufo:
			child.kill()
			child.visible = false
			
	Music.stop()
	player.set_process(false)
	player.set_process_input(false)


func _resume_game():
	for child in get_children():
		if child is Player or child is Enemy or child is EnemyProjectile or child is PlayerProjectile:
			child.set_process(true)
			child.set_process_input(true)


func _pause_game():
	for child in get_children():
		if child is Player or child is Enemy or child is EnemyProjectile or child is PlayerProjectile:			
			child.set_process(false)
			child.set_process_input(false)
