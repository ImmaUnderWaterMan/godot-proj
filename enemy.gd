extends CharacterBody2D

# Настройки врага
const SPEED = 100.0           # Скорость ходьбы (медленнее героя)
const DETECTION_RANGE = 200.0 # Радиус обзора
const ATTACK_COOLDOWN = 1.5   # Пауза между ударами
const ATTACK_RANGE = 40.0     # Расстояние, с которого можно бить

@onready var anim_sprite = $AnimatedSprite2D
@onready var detection_zone = $DetectionZone # Зона обнаружения
@onready var attack_timer = Timer.new()      # Таймер для кулдауна

var target: Node2D = null    # Ссылка на игрока
var is_attacking = false     # Флаг атаки

func _ready():
	# Настраиваем таймер
	attack_timer.wait_time = ATTACK_COOLDOWN
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_finished)

# Когда кто-то входит в зону видимости
func _on_detection_zone_body_entered(body):
	print("Кто-то вошел в зону! Это: ", body.name)
	if body.is_in_group("player"):
		print("Это ИГРОК! Начинаю погоню.") 
		target = body

# Когда кто-то выходит из зоны видимости
func _on_detection_zone_body_exited(body):
	if body == target:
		target = null
		anim_sprite.play("idle") # Возвращаемся к покою

func _physics_process(delta):
	# Если нет цели или мы атакуем — не двигаемся
	if target == null or is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
		# Если перестали видеть цель во время атаки, сбрасываем атаку
		if target == null and is_attacking:
			is_attacking = false 
			anim_sprite.play("idle")
			
		move_and_slide()
		return

	# --- ЛОГИКА ПРЕСЛЕДОВАНИЯ ---
	
	# Вычисляем направление к игроку
	var direction = (target.global_position - global_position).normalized()
	
	# Двигаемся к игроку
	velocity = direction * SPEED
	
	# Отражаем спрайт в сторону движения
	if direction.x != 0:
		anim_sprite.flip_h = (direction.x < 0)
	
	# Проверяем дистанцию для атаки
	var distance_to_player = global_position.distance_to(target.global_position)
	
	if distance_to_player <= ATTACK_RANGE and not is_attacking:
		start_attack()
	else:
		# Если далеко — просто идем
		if anim_sprite.animation != "walk":
			anim_sprite.play("walk")

	move_and_slide()

func start_attack():
	is_attacking = true
	velocity = Vector2.ZERO # Останавливаемся перед ударом
	anim_sprite.play("attack")
	attack_timer.start() # Запускаем таймер кулдауна

func _on_attack_finished():
	is_attacking = false
	# После удара снова проверяем, где игрок
	if target and global_position.distance_to(target.global_position) <= ATTACK_RANGE:
		start_attack()
	else:
		anim_sprite.play("walk")
