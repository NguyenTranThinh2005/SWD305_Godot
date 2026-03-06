extends CharacterBody2D
## VNEG_Godot/scripts/game/Player.gd
##
## Xử lý vật lý nhân vật, nhún nhảy và hoạt ảnh xoay ngược khi bị đổi trọng lực.

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Trọng lực mặc định của Project Settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_gravity_flipped = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if is_gravity_flipped:
			velocity.y -= gravity * delta # Kéo lên trên
		else:
			velocity.y += gravity * delta # Kéo xuống dưới

	# Handle jump.
	# Cấu hình "ui_accept" thường là phím Space / Enter
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if is_gravity_flipped:
			velocity.y = -JUMP_VELOCITY # Nhảy lún xuống (vì trần nhà là sàn)
		else:
			velocity.y = JUMP_VELOCITY  # Nhảy lên mây

	# Handle horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Thực thi hàm vật lý của Godot
	move_and_slide()

## Hàm này được gọi từ AntigravityWorld.gd mỗi khi trả lời đúng
func flip_gravity(flipped: bool) -> void:
	is_gravity_flipped = flipped
	
	# Tính toán Vector hướng Up tuân theo trọng lực
	# Khi Flipped, "Up" là hướng xuống dưới (Vector2.DOWN)
	up_direction = Vector2.DOWN if is_gravity_flipped else Vector2.UP
	
	# Tạo Tween để tạo hiệu ứng xoay từ từ (Flip 180 độ)
	var tween = create_tween()
	var target_rotation = PI if is_gravity_flipped else 0.0
	tween.tween_property(self, "rotation", target_rotation, 0.5).set_trans(Tween.TRANS_SPRING)
