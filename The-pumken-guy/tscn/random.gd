class_name Random
extends Node

@export var Variables : Array[Node2D] = []

func _ready() -> void:
	for i : Node2D in Variables:
		i.hide()
	var j = randi() % Variables.size()
	Variables[j].show()
