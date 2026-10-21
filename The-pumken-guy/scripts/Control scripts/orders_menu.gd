extends MenuBar

func _ready() -> void:
	hide()

func _on_orders_pressed() -> void:
	visible = !visible

func _on_attack_pressed() -> void:
	OrdersTaker.CurrentGoal = "Attack"

func _on_hold_the_position_pressed() -> void:
	OrdersTaker.CurrentGoal = "HoldThePosition"
