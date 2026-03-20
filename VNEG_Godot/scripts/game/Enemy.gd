extends CharacterBody2D
## VNEG_Godot/scripts/game/Enemy.gd

@export var speed: float = 60.0
@export var walk_range: float = 120.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_x: float
var direction: int = 1

func _ready():
	start_x = position.x
	# Cần 1 Area2D con để phát hiện va chạm với người chơi dễ dàng hơn
	# Nhưng ở đây ta dùng move_and_slide và kiểm tra va chạm trực tiếp cũng được
	# Để đơn giản, ta giữ 1 Area2D trong scene.

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Di chuyển ngang
	velocity.x = direction * speed
	
	move_and_slide()
	
	# Quay đầu khi chạm tường hoặc đi hết tầm
	if is_on_wall() or abs(position.x - start_x) > walk_range:
		direction *= -1
		if has_node("Sprite2D"):
			$Sprite2D.flip_h = (direction > 0)

func _on_hitbox_body_entered(body):
	if body is CharacterBody2D and body.name.to_lower().contains("player"):
		print("Player chạm quái! Reset vị trí.")
		# Đưa player về điểm xuất phát
		body.position = Vector2(100, 300)
		body.velocity = Vector2.ZERO
