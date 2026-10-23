class_name Map_node
extends Node2D

var is_transitioning: bool = false

func _physics_process(_delta: float) -> void:
	if MapData.Life == 0:
		set_physics_process(false)
		PlayerData.level += 1
		get_tree().change_scene_to_file("res://tscn/Worlds/map.tscn")
	else:
		return
