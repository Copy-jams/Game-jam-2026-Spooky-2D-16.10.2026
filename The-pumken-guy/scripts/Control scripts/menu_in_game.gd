extends MenuBar

@onready var settings: PanelContainer = $Settings

func _ready() -> void:
	hide()
	settings.hide()


func _on_button_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_button_2_pressed() -> void:
	settings.visible = !settings.visible


func _on_button_3_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://tscn/Control/menu.tscn")


func _on_button_4_pressed() -> void:
	get_tree().quit()
