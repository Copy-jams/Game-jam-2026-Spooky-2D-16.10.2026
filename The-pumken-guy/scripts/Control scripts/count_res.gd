extends VBoxContainer

@onready var corpses: Label = $corpses
@onready var souls: Label = $souls
@onready var armory: Label = $armory
@onready var close_quarters_combat_weapon: Label = $Close_quarters_combat_weapon
@onready var ranged_combat_weapon: Label = $Ranged_combat_weapon

func _process(delta: float) -> void:
	corpses.text = str(PlayerResources.corpses)
	souls.text = str(PlayerResources.souls)
	armory.text = str(PlayerResources.armory)
	close_quarters_combat_weapon.text = str(PlayerResources.close_quarters_combat_weapon)
	ranged_combat_weapon.text = str(PlayerResources.ranged_combat_weapon)
