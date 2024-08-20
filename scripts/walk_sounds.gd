extends Node

var _walk_up_sound: AudioStream = preload("res://assets/audio/walk_up.wav")
var _walk_down_sound: AudioStream = preload("res://assets/audio/walk_down.wav")

var _audio_player: AudioStreamPlayer
var _is_walking_up := true

func _ready():
	_audio_player = AudioStreamPlayer.new()
	add_child(_audio_player)


func play_walk_sounds():
	if _is_walking_up:
		_play_walk_up_sound()
	else:
		_play_walk_down_sound()
	_is_walking_up = !_is_walking_up


func _play_walk_up_sound():
	if not _audio_player.playing:
		_audio_player.stream = _walk_up_sound
		_audio_player.play()
		
		
func _play_walk_down_sound():
	if not _audio_player.playing:
		_audio_player.stream = _walk_down_sound
		_audio_player.play()
