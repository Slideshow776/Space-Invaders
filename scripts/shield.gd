extends Area2D

const MAX_HEALTH := 4

@export var bottom_left: bool
@export var top_left: bool
@export var middle: bool
@export var top_right: bool
@export var bottom_right: bool

var health = MAX_HEALTH
var textures_4: Array[CompressedTexture2D] = [
	preload("res://assets/shields/4/bottom_left.png"),
	preload("res://assets/shields/4/top_left.png"),
	preload("res://assets/shields/4/middle.png"),
	preload("res://assets/shields/4/top_right.png"),
	preload("res://assets/shields/4/bottom_right.png"),
]
var textures_3: Array[CompressedTexture2D] = [
	preload("res://assets/shields/3/bottom_left.png"),
	preload("res://assets/shields/3/top_left.png"),
	preload("res://assets/shields/3/middle.png"),
	preload("res://assets/shields/3/top_right.png"),
	preload("res://assets/shields/3/bottom_right.png"),
]
var textures_2: Array[CompressedTexture2D] = [
	preload("res://assets/shields/2/bottom_left.png"),
	preload("res://assets/shields/2/top_left.png"),
	preload("res://assets/shields/2/middle.png"),
	preload("res://assets/shields/2/top_right.png"),
	preload("res://assets/shields/2/bottom_right.png"),
]
var textures_1: Array[CompressedTexture2D] = [
	preload("res://assets/shields/1/bottom_left.png"),
	preload("res://assets/shields/1/top_left.png"),
	preload("res://assets/shields/1/middle.png"),
	preload("res://assets/shields/1/top_right.png"),
	preload("res://assets/shields/1/bottom_right.png"),
]

@onready var sprite_2d = %Sprite2D
@onready var breaking_effect = %BreakingEffect
@onready var explosion_effect = %ExplosionEffect


func _ready():
	area_entered.connect(_on_area_entered)
	_set_texture()


func _on_area_entered(area_entered: Area2D):
	health -= 1
	if health <= 0:
		queue_free()
	
	_set_texture()
	_bounce_animation()
	
	%AudioStreamPlayer.pitch_scale = randf_range(0.8, 1.2)
	%AudioStreamPlayer.play()
	breaking_effect.emitting = true
	explosion_effect.emitting = true


func _bounce_animation():
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	
	tween.tween_property(self, "scale", Vector2(1.1, 0.9), 0.1)	
	tween.tween_property(self, "scale", Vector2(0.95, 1.05), 2.0)
	tween.tween_property(self, "scale", Vector2.ONE, 1.5)


func _set_texture():
	if health > 4 or health < 1:
		return
	
	var texture: Texture2D = null
	match(health):
		4:
			if bottom_left:
				sprite_2d.texture = textures_4[0]
			elif top_left:
				sprite_2d.texture = textures_4[1]
			elif middle:
				sprite_2d.texture = textures_4[2]
			elif top_right:
				sprite_2d.texture = textures_4[3]
			elif bottom_right:
				sprite_2d.texture = textures_4[4]
		3:
			if bottom_left:
				sprite_2d.texture = textures_3[0]
			elif top_left:
				sprite_2d.texture = textures_3[1]
			elif middle:
				sprite_2d.texture = textures_3[2]
			elif top_right:
				sprite_2d.texture = textures_3[3]
			elif bottom_right:
				sprite_2d.texture = textures_3[4]
		2:
			if bottom_left:
				sprite_2d.texture = textures_2[0]
			elif top_left:
				sprite_2d.texture = textures_2[1]
			elif middle:
				sprite_2d.texture = textures_2[2]
			elif top_right:
				sprite_2d.texture = textures_2[3]
			elif bottom_right:
				sprite_2d.texture = textures_2[4]
		1:
			if bottom_left:
				sprite_2d.texture = textures_1[0]
			elif top_left:
				sprite_2d.texture = textures_1[1]
			elif middle:
				sprite_2d.texture = textures_1[2]
			elif top_right:
				sprite_2d.texture = textures_1[3]
			elif bottom_right:
				sprite_2d.texture = textures_1[4]
