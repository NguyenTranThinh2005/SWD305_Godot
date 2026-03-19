extends CharacterBody2D
## VNEG_Godot/scripts/game/Player.gd
##
## Xử lý vật lý nhân vật, nhún nhảy và hoạt ảnh xoay ngược khi bị đổi trọng lực.

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Trọng lực mặc định của Project Settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_gravity_flipped = false
var has_super_jump = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if is_gravity_flipped:
			velocity.y -= gravity * delta # Kéo lên trên
		else:
			velocity.y += gravity * delta # Kéo xuống dưới

	# Hardcode WASD support & UI focus bypass
	var jump_pressed = Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_SPACE)
	if jump_pressed and is_on_floor():
		var current_jump = JUMP_VELOCITY
		if has_super_jump:
			current_jump *= 1.6 # Nhảy cao hơn 60%
			has_super_jump = false # Dùng xong mất buff
			
		if is_gravity_flipped:
			velocity.y = -current_jump # Nhảy lún xuống (vì trần nhà là sàn)
		else:
			velocity.y = current_jump  # Nhảy lên mây

	# Handle horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): direction = -1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): direction = 1
	
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

func enable_super_jump() -> void:
	has_super_jump = true
	$Body.color = Color("#ff9600") # Bright orange to show buff
	await get_tree().create_timer(1.0).timeout
	$Body.color = Color(0.35, 0.7, 1.0) # Revert to blue
