class_name MapGenerator
extends Node2D

@export_group("Nodes")
@export var tilemap_layer : TileMapLayer # Ваш слой тайлов

@export_group("Map Settings")
@export var map_width : int = 80
@export_group("Map Settings")
@export var map_height : int = 80

@export_group("Noise Settings")
@export var noise_seed : int = 0
@export var noise_frequency : float = 0.05

var noise : FastNoiseLite

func _ready() -> void:
	_init_noise()
	generate_world()

func _init_noise() -> void:
	noise = FastNoiseLite.new()
	if noise_seed == 0:
		noise.seed = randi()
	else:
		noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_frequency

func generate_world() -> void:
	if not is_instance_valid(tilemap_layer):
		return

	tilemap_layer.clear()
	var land_cells : Array[Vector2i] = []
	
	# 1. ГЕНЕРАЦИЯ БАЗОВОГО ЛАНДШАФТА
	for x in range(map_width):
		for y in range(map_height):
			var noise_value : float = noise.get_noise_2d(x, y)
			var cell_pos := Vector2i(x, y)
			
			if noise_value < -0.1:
				tilemap_layer.set_cell(cell_pos, 0, Vector2i(0, 0)) # Вода
			else:
				tilemap_layer.set_cell(cell_pos, 0, Vector2i(1, 0)) # Земля
				land_cells.append(cell_pos)

	if land_cells.is_empty():
		return

	land_cells.shuffle()

	# 2. СТРОИТЕЛЬСТВО ЗАМКА И ЗОНЫ ДЛЯ НЕГО
	var castle_pos : Vector2i = land_cells.pop_back()
	tilemap_layer.set_cell(castle_pos, 0, Vector2i(4, 0))
	_spawn_interaction_zone(castle_pos, "Castle")

	# 3. РАССЕЛЕНИЕ ГОРОДОВ И ДЕРЕВЕНЬ И ИХ ЗОН
	for cell in land_cells:
		if Vector2(cell).distance_to(Vector2(castle_pos)) < 5.0:
			continue
			
		var spawn_chance : float = randf()
		
		if spawn_chance < 0.01:
			tilemap_layer.set_cell(cell, 0, Vector2i(3, 0)) # Город
			_spawn_interaction_zone(cell, "City")
		elif spawn_chance < 0.04:
			tilemap_layer.set_cell(cell, 0, Vector2i(2, 0)) # Деревня
			_spawn_interaction_zone(cell, "Village")

# --- ФУНКЦИЯ ДЛЯ СОЗДАНИЯ ФИЗИЧЕСКОЙ ЗОНЫ НА КАРТЕ ---
func _spawn_interaction_zone(tile_coords: Vector2i, building_type: String) -> void:
	# 1. Создаем узел Area2D
	var zone := Area2D.new()
	zone.name = building_type + "_Zone_" + str(tile_coords.x) + "_" + str(tile_coords.y)
	
	# Переводим координаты клетки в пиксельные координаты мира Godot
	zone.global_position = tilemap_layer.map_to_local(tile_coords)
	
	# 2. Создаем форму коллизии (круглая зона вокруг постройки)
	var collision_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 32.0 # Радиус зоны в пикселях (примерно равен размеру тайла)
	collision_shape.shape = circle
	
	# Добавляем форму внутрь Area2D
	zone.add_child(collision_shape)
	
	# Настраиваем метаданные, чтобы игрок/код понимал, что это за место
	zone.set_meta("building_type", building_type)
	zone.set_meta("tile_coords", tile_coords)
	
	# 3. Подключаем сигнал: когда КТО-ТО заходит в эту зону
	zone.body_entered.connect(func(body: Node2D):
		_on_building_zone_entered(body, zone)
	)
	
	# Добавляем зону на сцену (она будет жить под картой в мировых координатах)
	add_child(zone)

# --- ОБЩИЙ ОБРАБОТЧИК ДЛЯ ВСЕХ ЗОН НА КАРТЕ ---
func _on_building_zone_entered(body: Node2D, zone: Area2D) -> void:
	# Проверяем, кто именно зашел в зону (например, юнит игрока)
	if body is PlayerUnit:
		var type = zone.get_meta("building_type")
		var coords = zone.get_meta("tile_coords")
		
		match type:
			"Village":
				print("Юнит ", body.name, " вошел в зону Деревни на координатах ", coords)
				# Ваша логика: захват, выдача ресурсов и т.д.
			"City":
				print("Юнит ", body.name, " подошел к Городу ", coords)
			"Castle":
				print("Юнит у Замка!")
