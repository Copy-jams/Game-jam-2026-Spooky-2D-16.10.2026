class_name EnemyUnit
extends CharacterBody2D

@export_group("Base")
@export var health : float = 10
@export var speed : int = 400
@export var attackDamage : float = 2.5
@export var attackTimeout : float = 1.5 
@export var protection : float = 1

@export_group("Reward")
@export var souls : int = 1
@export var corpses : int = 1
@export var armor : int = 0
@export var close_quarters_combat_weapon : int = 0
@export var ranged_combat_weapon : int = 0

@export_group("Scenes")
@export var peaceful : bool = false
@export var navigationAgent : NavigationAgent2D
@export var targetPosition : Node2D 
@export var animation : AnimationPlayer
@export var body_container : Node2D 
@export var audioPlayer : AudioStreamPlayer2D

const SCREAM_2 = preload("uid://bgbymsxotcfoi")
const SCREAM = preload("uid://dpldi6knd46yc")

var currentTarget : CharacterBody2D
var can_attack : bool = true
var is_dead : bool = false
var can_run : bool = true

func _ready() -> void:
	OrdersTaker.add_to_group_EnemyUnits(self)
	MapData.Life += 1
	if is_instance_valid(targetPosition):
		targetPosition.global_position = global_position
		
	navigationAgent.target_desired_distance = 100
		
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if health <= 0 or is_dead:
		death()
		return
	
	print(velocity)
	_handle_running_animation(delta)
	
	var force_stop : bool = false
	
	# ИСПРАВЛЕНО: Теперь враг постоянно ищет БЛИЖАЙШУЮ цель, а не «залипает» на одной
	currentTarget = OrdersTaker.get_near_player(global_position)
	
	# АГРЕССИВНОЕ ПОВЕДЕНИЕ
	if not peaceful:
		if is_instance_valid(currentTarget) and is_instance_valid(targetPosition):
			var distance_to_player = global_position.distance_to(currentTarget.global_position)
			
			if distance_to_player <= 250.0:
				targetPosition.global_position = currentTarget.global_position
			else:
				targetPosition.global_position = global_position
				force_stop = true
			
	# МИРНОЕ / ТРУСЛИВОЕ ПОВЕДЕНИЕ
	else:
		if is_instance_valid(currentTarget) and is_instance_valid(targetPosition):
			var distance_to_player = global_position.distance_to(currentTarget.global_position)
			
			# ИСПРАВЛЕНО: Безопасное отбегание без утечки таймеров
			if distance_to_player < 500.0 and can_run:
				can_run = false
				var flee_direction = currentTarget.global_position.direction_to(global_position)
				flee_direction = flee_direction.rotated(randf_range(-0.7, 0.7))
				targetPosition.global_position = global_position + flee_direction * 350.0
				if audioPlayer:
					var r = randi() % 2
					match r:
						0: audioPlayer.stream = SCREAM
						1: audioPlayer.stream = SCREAM_2
					audioPlayer.pitch_scale = randf_range(0.8,1.2)
					audioPlayer.play()
				# Переназначаем точку ИИ сразу
				navigationAgent.target_position = targetPosition.global_position
				
				# Таймер перезарядки трусости
				get_tree().create_timer(2.0).timeout.connect(func(): can_run = true)

	if not is_instance_valid(targetPosition):
		#velocity = Vector2.ZERO
		_play_animation("idle")
		move_and_slide()
		return
	
	# Для мирного ИИ точка уже принудительно обновилась выше при старте бега
	if not peaceful or (peaceful and not can_run):
		navigationAgent.target_position = targetPosition.global_position
	
	if navigationAgent.is_navigation_finished() or force_stop:
		#velocity = Vector2.ZERO
		
		if not peaceful and is_instance_valid(currentTarget) and not force_stop:
			attack()
		else:
			_play_animation("idle")
	else:
		move()
	
	move_and_slide()

func attack() -> void:
	if not can_attack or not is_instance_valid(currentTarget):
		return
		
	can_attack = false
	_play_animation("attack")
	_flip_towards(currentTarget.global_position)
	
	# ИСПРАВЛЕНО: Передаем attacker (self), если это поддерживает метод игрока, 
	# либо метод игрока должен быть приведен к такому же виду, как get_damage ниже.
	if currentTarget.has_method("get_damage"):
		# Если у игрока метод принимает 2 аргумента:
		currentTarget.get_damage(attackDamage, self) 
	
	if "health" in currentTarget:
		print(self.name, " кусает ", currentTarget.name, " (HP цели: ", currentTarget.health, ")")
	
	var timer := get_tree().create_timer(attackTimeout)
	timer.timeout.connect(func(): can_attack = true)

# ИСПРАВЛЕНО: Добавлен необязательный аргумент attacker, чтобы избежать вылетов,
# если другие скрипты передают того, кто нанес урон.
func get_damage(damage : float, _attacker: Node2D = null) -> void:
	var final_damage = max(0.5, damage - protection)
	health -= final_damage

func move() -> void:
	var next_path_position : Vector2 = navigationAgent.get_next_path_position()
	var direction : Vector2 = global_position.direction_to(next_path_position)
	#velocity = direction * speed
	
	
	_flip_towards(next_path_position)

# --- ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДЛЯ АНИМАЦИИ И РАЗВОРOTА ---

func _play_animation(anim_name: String) -> void:
	if is_instance_valid(animation) and animation.has_animation(anim_name):
		if animation.current_animation == "attack" and anim_name != "attack" and animation.is_playing():
			return
		# ИСПРАВЛЕНО: Если проигрывается смерть, не прерываем её ничем
		if animation.current_animation == "death":
			return
		animation.play(anim_name)

func _flip_towards(target_pos: Vector2) -> void:
	if not is_instance_valid(body_container):
		return
		
	if target_pos.x > global_position.x:
		body_container.scale.x = abs(body_container.scale.x)
	elif target_pos.x < global_position.x:
		body_container.scale.x = -abs(body_container.scale.x)

func death() -> void:
	if is_dead: return
	is_dead = true
	
	# Отключаем физику и коллизии сразу, чтобы мертвый враг не мешал ходить и не атаковал
	set_physics_process(false)
	#velocity = Vector2.ZERO
	
	PlayerResources.corpses += corpses
	PlayerResources.souls += souls
	PlayerResources.armory += armor
	PlayerResources.close_quarters_combat_weapon += close_quarters_combat_weapon
	PlayerResources.ranged_combat_weapon += ranged_combat_weapon
	
	OrdersTaker.del_in_group_EnemyUnits(self)
	
	# ИСПРАВЛЕНО: Ожидаем завершения анимации смерти перед полным удалением
	if is_instance_valid(animation) and animation.has_animation("death"):
		animation.play("death")
		await animation.animation_finished
	MapData.Life -= 1
	if name == "King":
		get_tree().change_scene_to_file("res://tscn/Control/end.tscn")
	queue_free()


#производит анимацию для юнита когда он движется (вызывать функцию каждый кадр)
@export var texture_root: Node2D
var t: float = 1
var amplitude = 10 # на сколько высоко прыгает юнит
var period = 10 # как быстро прыгает юнит
var max_rotation: float = 30 #максиматлный наклон при прышке
func _handle_running_animation(_delta) -> void:
	if texture_root == null: return
	t += period * _delta
	if velocity == Vector2.ZERO: return
	var offset = sin(t) * amplitude * velocity.length() / speed 
	texture_root.position.y = -abs(offset)
	texture_root.rotation_degrees = clamp(offset, -max_rotation, max_rotation)
