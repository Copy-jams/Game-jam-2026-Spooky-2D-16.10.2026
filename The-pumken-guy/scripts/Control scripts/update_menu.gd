extends MenuBar

var nearE : PlayerUnit = null

func _ready() -> void:
	hide()

func _on_updates_pressed() -> void:
	visible = !visible


# --- КНОПКИ УЛУЧШЕНИЯ БРОНИ ---

func _on_armor_zombie_pressed() -> void:
	var Units : Array[PlayerUnit] = []
	for i in OrdersTaker.PlayerUnits:
		# Унифицировано: ищем по CallSign (чувствительно к регистру!)
		if is_instance_valid(i) and i.get("CallSign") == "Zombie" and i.canWearArmor:
			Units.append(i)
	find_near(Units, "armor")


func _on_armor_skeleton_pressed() -> void:
	var Units : Array[PlayerUnit] = []
	for i in OrdersTaker.PlayerUnits:
		if is_instance_valid(i) and i.get("CallSign") == "Skeleton" and i.canWearArmor:
			Units.append(i)
	find_near(Units, "armor")


func _on_armor_homuclus_pressed() -> void:
	var Units : Array[PlayerUnit] = []
	for i in OrdersTaker.PlayerUnits:
		if is_instance_valid(i) and i.get("CallSign") == "Homunculus" and i.canWearArmor:
			Units.append(i)
	find_near(Units, "armor")


# --- КНОПКИ ВЫДАЧИ ОРУЖИЯ ---

func _on_weapon_zombie_pressed() -> void:
	var Units : Array[PlayerUnit] = []
	for i in OrdersTaker.PlayerUnits:
		if is_instance_valid(i) and i.get("CallSign") == "Zombie" and i.weaponInArms == "n":
			Units.append(i)
	find_near(Units, "weapon")


func _on_weapon_skeleton_pressed() -> void:
	var Units : Array[PlayerUnit] = []
	for i in OrdersTaker.PlayerUnits:
		if is_instance_valid(i) and i.get("CallSign") == "Skeleton" and i.weaponInArms == "n":
			Units.append(i)
	find_near(Units, "weapon")


func _on_weapon_homuclus_pressed() -> void:
	var Units : Array[PlayerUnit] = []
	for i in OrdersTaker.PlayerUnits:
		if is_instance_valid(i) and i.get("CallSign") == "Homunculus" and i.weaponInArms == "n":
			Units.append(i)
	find_near(Units, "weapon")


# --- СИСТЕМА ПОИСКА И АВТО-ПРИМЕНЕНИЯ ---

func find_near(array : Array[PlayerUnit], whatUpdate : String) -> void:
	nearE = null
	var min_distance: float = INF
	
	for player: PlayerUnit in array:
		if not is_instance_valid(player):
			continue
			
		var distance: float = PlayerData.pos.distance_squared_to(player.global_position)
		
		if distance < min_distance:
			min_distance = distance
			nearE = player
			
	# Если подходящий близкий юнит найден — сразу применяем улучшение
	if is_instance_valid(nearE):
		if whatUpdate == "armor":
			nearE.level_up_armory()
		elif whatUpdate == "weapon":
			nearE.give_weapon()
	else:
		print("Рядом нет подходящих юнитов для улучшения типа: ", whatUpdate)
