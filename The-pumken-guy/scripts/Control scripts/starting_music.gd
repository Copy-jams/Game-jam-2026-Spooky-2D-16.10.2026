extends Node

@export var Music : AudioStreamMP3 
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	audio_stream_player.stream = Music
	audio_stream_player.play()
