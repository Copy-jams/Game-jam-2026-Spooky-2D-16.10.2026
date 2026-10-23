extends AnimatedSprite2D

func _ready() -> void:
	next_frame()

func next_frame():
	await get_tree().create_timer(1.5).timeout
	frame += 1
	if frame != 12:
		next_frame()
	else:
		get_tree().change_scene_to_file("res://tscn/Worlds/map.tscn")
