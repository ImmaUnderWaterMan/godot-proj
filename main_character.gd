extends CharacterBody2D

const SPEED = 300.0

@onready var anim_sprite = $AnimatedSprite2D

# Флаг, который запрещает прерывать атаку ходьбой
var is_attacking := false

func _physics_process(delta: float) -> void:
	# 1. Обработка ввода для атаки 
	if Input.is_action_just_pressed("ui_select") and not is_attacking: 
		is_attacking = true
		anim_sprite.play("swing")
		velocity.x = 0
		velocity.y = 0
		
	# 2. Обработка движения
	var direction_x := Input.get_axis("ui_left", "ui_right")
	var direction_y := Input.get_axis("ui_up", "ui_down")
	
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# 3. Логика анимации (Приоритет №2)
	if not is_attacking:
		if velocity.is_zero_approx():
			anim_sprite.play("idle")
		else:
			anim_sprite.play("walk")
		if direction_x != 0:
			anim_sprite.flip_h = (direction_x < 0)

	move_and_slide()

# 4. Сигнал окончания анимации
func _on_animated_sprite_2d_animation_finished():
	if anim_sprite.animation == "swing":
		is_attacking = false
		if velocity.is_zero_approx():
			anim_sprite.play("idle")
		else:
			anim_sprite.play("walk")
