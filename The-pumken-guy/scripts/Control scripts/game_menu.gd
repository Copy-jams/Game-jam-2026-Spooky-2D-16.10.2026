extends Control

@onready var menu: MenuBar = $Menu

func _on_menu_pressed() -> void:
	get_tree().paused = !get_tree().paused
	menu.visible = get_tree().paused
