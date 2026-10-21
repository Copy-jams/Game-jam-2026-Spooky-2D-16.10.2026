extends Node2D

# Перетащите в эти экспортные поля ваши сцены локаций (сцена деревни, города, замка)
@export var castle_scene : PackedScene
@export var city_scene : PackedScene
@export var village_scene : PackedScene

# ИСПРАВЛЕНО: Ссылки на дочерние узлы собираем через @onready, иначе игра вылетит на старте
@onready var points_array : Array[Node2D] = [
	$Node2D, $Node2D2, $Node2D3, $Node2D4, $Node2D5, $Node2D6, 
	$Node2D7, $Node2D8, $Node2D9, $Node2D10, $Node2D11, $Node2D12
]

const castles = 1
const citys = 4
const villages = 7


func _ready() -> void:
	# 1. Создаем общий список того, ЧТО нам нужно заспавнить (всего 12 штук)
	var spawn_queue : Array[String] = []
	
	for i in range(castles):
		spawn_queue.append("Castle")
	for i in range(citys):
		spawn_queue.append("City")
	for i in range(villages):
		spawn_queue.append("Village")
		
	# 2. Перемешиваем колоду наших точек, чтобы распределение было полностью случайным
	points_array.shuffle()
	
	# 3. Проходим по каждой точке и спавним на ней соответствующий объект
	for i in range(points_array.size()):
		var current_point = points_array[i]
		var type_to_spawn = spawn_queue[i]
		
		# Защита: проверяем, существует ли точка
		if not is_instance_valid(current_point):
			continue
			
		_spawn_location_at(current_point, type_to_spawn)


func _spawn_location_at(point: Node2D, type: String) -> void:
	var instance : EnterLocation = null
	
	# Выбираем, какую сцену инстанцировать
	match type:
		"Castle":
			if is_instance_valid(castle_scene):
				instance = castle_scene.instantiate()
		"City":
			if is_instance_valid(city_scene):
				instance = city_scene.instantiate()
		"Village":
			if is_instance_valid(village_scene):
				instance = village_scene.instantiate()
				
	# Если сцена успешно создана, привязываем её к точке
	if instance:
		# Переносим её физически на координаты нашей точки $Node2D
		instance.global_position = point.global_position
		
		# Задаем тип (помните, в вашем скрипте EnterLocation есть переменная type?)
		instance.type = type
		
		# Добавляем на сцену
		add_child(instance)
