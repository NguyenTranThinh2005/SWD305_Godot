extends Area2D
## VNEG_Godot/scripts/game/Spikes.gd

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D and body.name.to_lower().contains("player"):
		print("Player giẫm phải chông! Reset vị trí.")
		# Đưa player về điểm xuất phát
		body.position = Vector2(100, 300)
		body.velocity = Vector2.ZERO
