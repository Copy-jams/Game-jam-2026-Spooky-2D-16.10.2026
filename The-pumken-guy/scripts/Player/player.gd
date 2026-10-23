extends CharacterBody2D

var speed : int = 300
var health : float = 10.0
var protection : float = 2.5
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	PlayerData.player = self

func _physics_process(delta: float) -> void:
	if health <= 0:
		death()
		return
	if velocity and Input.is_action_pressed("A"):
		animationPlayer.play("MoveLeft")
	elif velocity and Input.is_action_pressed("D"):
		animationPlayer.play("MoveRight")
	elif velocity and Input.is_action_pressed("W") or Input.is_action_just_pressed("S"):
		animationPlayer.play("Move")

	var directions : Vector2 = Input.get_vector("A","D","W","S").normalized()

	velocity = directions * speed

	PlayerData.pos = global_position

	move_and_slide()

func get_damage(damage : float, e : EnemyUnit ):
	var final_damage = max(0.5, damage - protection)
	health -= final_damage

func death() -> void:
	# Отключаем обработку физики, чтобы игрок больше не двигался и не получал урон
	set_physics_process(false)
	
	# Сбрасываем скорость, чтобы персонаж мгновенно остановился
	velocity = Vector2.ZERO
	
	# Проверяем, есть ли анимация смерти в AnimationPlayer, и запускаем её
	if animationPlayer.has_animation("Death"):
		animationPlayer.play("Death")
		# Ждем, пока анимация полностью проиграется, прежде чем менять сцену
		await animationPlayer.animation_finished
	else:
		# Если анимации нет, выводим предупреждение в консоль
		push_warning("Анимация 'Death' не найдена в AnimationPlayer!")
	
	# ВАЖНО: Очищаем ссылку на игрока в глобальном синглтоне перед сменой сцены
	if is_instance_valid(PlayerData) and PlayerData.get("player") == self:
		PlayerData.player = null
	
	# Переходим в главное меню игры
	get_tree().change_scene_to_file("res://tscn/Control/menu.tscn")
