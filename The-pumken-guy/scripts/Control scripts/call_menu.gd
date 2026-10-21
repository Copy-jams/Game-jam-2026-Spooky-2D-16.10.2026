extends MenuBar

const GHOST = preload("uid://b6lx1spy17dcg")
const HOMUNCULUS = preload("uid://dpb8g25f7hhqa")
const SKELETON_WIZARD = preload("uid://dc5osk66fsli2")
const SKELETON = preload("uid://clxvf5386mp6l")
const ZOMBIE = preload("uid://d2uq40ys5kock")


var ins : Node2D

func _ready() -> void:
	hide()

func _on_сall_pressed() -> void:
	visible = !visible

func _on_ghost_pressed() -> void:
	ins = GHOST.instantiate()
	ins.global_position = PlayerData.pos + Vector2(randi_range(-50,50),randi_range(-50,50))
	PlayerData.player.get_parent().add_child(ins)

func _on_zombie_pressed() -> void:
	ins = ZOMBIE.instantiate()
	ins.global_position = PlayerData.pos + Vector2(randi_range(-50,50),randi_range(-50,50))
	PlayerData.player.get_parent().add_child(ins)


func _on_skeleton_pressed() -> void:
	ins = SKELETON.instantiate()
	ins.global_position = PlayerData.pos + Vector2(randi_range(-50,50),randi_range(-50,50))
	PlayerData.player.get_parent().add_child(ins)



func _on_homunculus_pressed() -> void:
	ins = HOMUNCULUS.instantiate()
	ins.global_position = PlayerData.pos + Vector2(randi_range(-50,50),randi_range(-50,50))
	PlayerData.player.get_parent().add_child(ins)


func _on_skeleton_mage_pressed() -> void:
	ins = SKELETON_WIZARD.instantiate()
	ins.global_position = PlayerData.pos + Vector2(randi_range(-50,50),randi_range(-50,50))
	PlayerData.player.get_parent().add_child(ins)
