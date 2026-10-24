extends Control


func _ready() -> void:
	MainMusicPlayer.stop()
	PlayerData.reload()
	PlayerResources.reload()
	MapData.Life = 0

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Control/intro.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_graybox_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Worlds/gray_box.tscn")
