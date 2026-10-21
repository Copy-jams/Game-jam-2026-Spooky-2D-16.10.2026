extends Control

@export var intro_sprite: AnimatedSprite2D
@export var autodiologe: Timer
@export var audio_stream_player: AudioStreamPlayer
@export var skip_icon: TextureRect
var current_pannel: int = 1

func _ready() -> void:
	audio_stream_player.play()


func next_frame():
	current_pannel += 1
	intro_sprite.play("panel"+str(current_pannel))
	skip_icon.visible = false
	
	if current_pannel == 10:
		get_tree().change_scene_to_file("res://tscn/Worlds/map.tscn")


func _on_next_pressed() -> void:
	next_frame()




func _on_animated_sprite_2d_animation_finished() -> void:
	skip_icon.visible = true
