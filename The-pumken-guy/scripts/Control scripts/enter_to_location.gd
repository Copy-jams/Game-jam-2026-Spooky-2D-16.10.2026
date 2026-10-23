class_name EnterLocation
extends Node2D

@export var currertMap : PackedScene
@export var needLevel : int

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(currertMap)

func _physics_process(delta: float) -> void:
	if PlayerData.level < needLevel:
		hide()
	else:
		show()
	if PlayerData.level > needLevel:
		process_mode = Node.PROCESS_MODE_WHEN_PAUSED
