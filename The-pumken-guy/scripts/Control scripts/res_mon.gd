extends MenuBar

func _ready() -> void:
	hide()

func _on_resources_pressed() -> void:
	visible = !visible
