class_name PlayerUnit
extends CharacterBody2D

@export_group("Base")
@export var CallSign : String = "Name"
@export var health : float = 10
@export var speed : int = 300
@export var attackDamage : float = 2.5
@export var attackTimeout : float = 2.0
@export var protection : float = 1
@export_enum("Close-quarters combat","Ranged combat","n") var weaponInArms : String = "n"

@export_group("Can improvement")
@export_enum("Close-quarters combat","Ranged combat","n") var typeWeapon : String = "n"
@export var canWearArmor : bool = false

@export_group("Price")
@export var souls : int = 1
@export var corpses : int = 1

@export_group("Improvement")
@export var armorNeededForUpgrades : int = 1
@export var soulsNeededForUpgrades : int = 1

@export_group("Scenes")
@export var navigationAgent : NavigationAgent2D
@export var targetPosition : Node2D 
@export var animationPlayer : AnimationPlayer
@export var body : Node2D
@export var ProjrectileStartPosition : Node2D
@export var projectile : PackedScene
@export var Armory : Node2D
@export var Weapon : Node2D
@export var SoundPlayer : AudioStreamPlayer2D

var currentEnemy : EnemyUnit
var can_attack : bool = true
var is_dead : bool = false 


func _ready() -> void:
	# Безопасная проверка стоимости спавна юнита
	if PlayerResources.souls < souls or PlayerResources.corpses < corpses:
		queue_free()
		return # Мгновенно выходим, чтобы код ниже не выполнялся
		
	# Списываем ресурсы за создание
	PlayerResources.souls -= souls
	PlayerResources.corpses -= corpses

	if is_instance_valid(SoundPlayer):
		SoundPlayer.play()
	if is_instance_valid(Armory):
		Armory.hide()
	if is_instance_valid(Weapon):
		Weapon.hide()
	
	if is_instance_valid(targetPosition):
		targetPosition.global_position = global_position
	
	_setup_attack_distance()
	OrdersTaker.add_to_group_PlayerUnits(self)


func _setup_attack_distance() -> void:
	match weaponInArms:
		"Close-quarters combat":
			navigationAgent.target_desired_distance = 100.0
		"Ranged combat":
			navigationAgent.target_desired_distance = 500.0
		_:
			navigationAgent.target_desired_distance = 200.0


func _physics_process(delta: float) -> void:
	if health <= 0 or is_dead:
		death()
		return

	if is_instance_valid(SoundPlayer):
		SoundPlayer.volume_db = WorldSettings.SoundsVolume
	
	# Секция 1: Логика выбора цели
	if OrdersTaker.CurrentGoal == "Attack":
		if not is_instance_valid(currentEnemy):
			currentEnemy = OrdersTaker.get_near_enemy(global_position)
			
		if is_instance_valid(currentEnemy) and is_instance_valid(targetPosition):
			targetPosition.global_position = currentEnemy.global_position
	
	# Секция 2: Обновление позиции навигации
	if is_instance_valid(targetPosition):
		navigationAgent.target_position = targetPosition.global_position
	
	# Секция 3: Движение или Остановка + Атака
	if OrdersTaker.CurrentGoal == "HoldThePosition" or navigationAgent.is_navigation_finished():
		velocity = Vector2.ZERO
		_play_animation("idle")
		
		# Авторазворот к врагу во время стояния/атаки
		if is_instance_valid(currentEnemy):
			_flip_towards(currentEnemy.global_position)
			
		if OrdersTaker.CurrentGoal == "Attack" and is_instance_valid(currentEnemy):
			attack()
	else:
		move()
	
	move_and_slide()


func attack() -> void:
	if not can_attack:
		return
		
	can_attack = false
	_play_animation("attack")
	
	if weaponInArms == "Ranged combat":
		if is_instance_valid(projectile) and is_instance_valid(ProjrectileStartPosition):
			var ins : Projectile = projectile.instantiate()
			ins.global_position = ProjrectileStartPosition.global_position
			ins.Damage = attackDamage
			ins.target = currentEnemy
			ins.sender = self
			get_parent().add_child(ins)
	else:
		if is_instance_valid(currentEnemy):
			currentEnemy.get_damage(attackDamage)
			
	print(self.name, " attacks ", currentEnemy.name, " (Remaining HP: ", currentEnemy.health, ")")
	
	var timer := get_tree().create_timer(attackTimeout)
	timer.timeout.connect(func(): can_attack = true)


func level_up_armory() -> void:
	if not canWearArmor:
		print("Этот юнит не может носить броню или уже экипирован!")
		return

	if PlayerResources.armory < armorNeededForUpgrades:
		print("Недостаточно брони на складе! Нужно: ", armorNeededForUpgrades)
		return

	PlayerResources.armory -= armorNeededForUpgrades
	canWearArmor = false
	protection += 2.5
	if is_instance_valid(Armory):
		Armory.show()

	print(self.name, " успешно улучшил броню! Текущая защита: ", protection)


func give_weapon() -> void:
	# ИСПРАВЛЕНО: Проверяем, что оружия на складе БОЛЬШЕ ИЛИ РАВНО 1, и корректно его списываем
	if typeWeapon == "Ranged combat" and PlayerResources.ranged_combat_weapon >= 1:
		PlayerResources.ranged_combat_weapon -= 1
		weaponInArms = "Ranged combat"
		typeWeapon = "n"
		_setup_attack_distance()
		if is_instance_valid(Weapon): Weapon.show()
		
	elif typeWeapon == "Close-quarters combat" and PlayerResources.close_quarters_combat_weapon >= 1:
		PlayerResources.close_quarters_combat_weapon -= 1
		weaponInArms = "Close-quarters combat"
		typeWeapon = "n"
		_setup_attack_distance()
		if is_instance_valid(Weapon): Weapon.show()
	else:
		print("Недостаточно оружия нужного типа на складе ресурсов!")


func get_damage(damage : float, e : EnemyUnit):
	# Запоминаем атаковавшего врага как цель, только если это ближний бой
	if is_instance_valid(e) and e.get("ranged_combat_weapon") == 0:
		currentEnemy = e
		
	var final_damage = max(0.5, damage - protection)
	health -= final_damage


func move() -> void:
	var next_path_position : Vector2 = navigationAgent.get_next_path_position()
	var direction : Vector2 = global_position.direction_to(next_path_position)
	velocity = direction * speed
	
	# АНИМАЦИЯ И РАЗВОРOT ПРИ ХОДЬБЕ:
	_play_animation("run")
	_flip_towards(next_path_position)


# --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ АНИМАЦИИ И РАЗВОРOTА ---

func _play_animation(anim_name: String) -> void:
	if is_instance_valid(animationPlayer) and animationPlayer.has_animation(anim_name):
		# Анимация атаки имеет высший приоритет и не прерывается бегом или idle
		if animationPlayer.current_animation == "attack" and anim_name != "attack" and animationPlayer.is_playing():
			return
		animationPlayer.play(anim_name)


func _flip_towards(target_pos: Vector2) -> void:
	if not is_instance_valid(body):
		return
	# Если цель правее нас — смотрим направо (scale.x > 0)
	if target_pos.x < global_position.x:
		body.scale.x = abs(body.scale.x)
	# Если цель левее нас — отзеркаливаем налево (scale.x < 0)
	elif target_pos.x > global_position.x:
		body.scale.x = -abs(body.scale.x)


func death():
	if is_dead: return
	is_dead = true
	set_physics_process(false)
	OrdersTaker.del_in_group_PlayerUnits(self)
	queue_free()
