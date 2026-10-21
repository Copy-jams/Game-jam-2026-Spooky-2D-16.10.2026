class_name Projectile
extends CharacterBody2D

@export var Speed : int = 500
@export var projectile : Node2D # Ссылка на спрайт/визуал снаряда для поворота

var sender 
var Damage : float = 2
var direction : Vector2
var target : Node2D # Безопасно типизируем цель


func _ready() -> void:
	if is_instance_valid(target):
		direction = global_position.direction_to(target.global_position)
		if is_instance_valid(projectile):
			projectile.look_at(target.global_position)
	else:
		queue_free()


func _physics_process(delta: float) -> void:
	# 1. ЗАЩИТА: Проверяем, существует ли цель, пока летим
	if not is_instance_valid(target):
		queue_free() # Если цель умерла в полете, снаряд просто исчезает
		return

	# 2. Считаем расстояние до цели
	var distance : float = global_position.distance_to(target.global_position)
	
	# 3. Логика попадания
	if distance < 30.0: # 50 пикселей может быть многовато, уменьшили до 30 для точности
		target.get_damage(Damage,sender)
		queue_free() # ОБЯЗАТЕЛЬНО: Удаляем снаряд после попадания!
		return
	
	# 4. Движение снаряда
	velocity = direction * Speed
	move_and_slide()
