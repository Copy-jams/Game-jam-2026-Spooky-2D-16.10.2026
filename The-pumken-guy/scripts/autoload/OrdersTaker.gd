extends Node

var CurrentGoal: String = "n"
var PlayerUnits: Array[PlayerUnit] = []
var EnemyUnits: Array[EnemyUnit] = []

var nearP: PlayerUnit
var nearE: EnemyUnit

const ATTACK = preload("uid://cmd4hngioj867")

func _physics_process(_delta: float) -> void:
	# Безопасная проверка: если врагов нет, останавливаем музыку
	# Используем метод, фильтрующий удаленные объекты
	if get_valid_enemy_count() == 0 and MainMusicPlayer.is_playing():
		MainMusicPlayer.stop()

## Поиск ближайшего врага
func get_near_enemy(pos: Vector2) -> EnemyUnit:
	var near_enemy: EnemyUnit = null
	var min_distance: float = INF
	
	for enemy in EnemyUnits:
		if not is_instance_valid(enemy):
			continue
		
		var distance: float = pos.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			near_enemy = enemy
			
	return near_enemy

## Поиск ближайшего юнита игрока или самого игрока
func get_near_player(pos: Vector2) -> Node2D: # Возвращает Node2D, так как Player и PlayerUnit могут быть разными классами
	var near_player: Node2D = null
	var min_distance: float = INF
	
	# Шаг 1: Поиск среди подчиненных юнитов игрока
	for player in PlayerUnits:
		if not is_instance_valid(player):
			continue
			
		var distance: float = pos.distance_squared_to(player.global_position)
		if distance < min_distance:
			min_distance = distance
			near_player = player
			
	# Шаг 2: Проверка дистанции до главного героя (PlayerData)
	if is_instance_valid(PlayerData):
		var main_player = PlayerData.get("player")
		if is_instance_valid(main_player) and "global_position" in main_player:
			var dist_to_main_player: float = pos.distance_squared_to(main_player.global_position)
			
			if dist_to_main_player < min_distance:
				near_player = main_player
				
	return near_player

# Вспомогательный метод для подсчета живых врагов
func get_valid_enemy_count() -> int:
	var count := 0
	for enemy in EnemyUnits:
		if is_instance_valid(enemy):
			count += 1
	return count

# Регистрирующие функции (с проверкой на дубликаты)
func add_to_group_PlayerUnits(body: PlayerUnit) -> void:
	if not PlayerUnits.has(body):
		PlayerUnits.append(body)

func add_to_group_EnemyUnits(body: EnemyUnit) -> void:
	if not EnemyUnits.has(body):
		EnemyUnits.append(body)

func del_in_group_PlayerUnits(body: PlayerUnit) -> void:
	PlayerUnits.erase(body)

func del_in_group_EnemyUnits(body: EnemyUnit) -> void:
	EnemyUnits.erase(body)
