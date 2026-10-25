extends MenuBar

@onready var label: Label = $PanelContainer/HBoxContainer/Label
@onready var max: Label = $PanelContainer/HBoxContainer/Label3

func _physics_process(delta: float) -> void:
	var l
	match PlayerData.level:
		0: l = 5
		1: l = 10
		2: l = 20
	max.text = str(l)
	label.text = str(OrdersTaker.PlayerUnits.size())
