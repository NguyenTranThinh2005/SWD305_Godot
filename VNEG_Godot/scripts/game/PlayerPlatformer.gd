extends CharacterBody2D
class_name PlayerPlatformer

const SPEED = 350.0
const JUMP_VELOCITY = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = 1500

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Flip visual based on direction
	if velocity.x < 0:
		$Eye1.position.x = -14
		$Eye2.position.x = -6
	elif velocity.x > 0:
		$Eye1.position.x = -2
		$Eye2.position.x = 6

	move_and_slide()
