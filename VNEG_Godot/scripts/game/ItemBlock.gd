extends StaticBody2D
## VNEG_Godot/scripts/game/ItemBlock.gd
##
## Khối gạch (Brick) chứa Game (Ngữ pháp, Chính tả, v.v.).
## Khi Mario nhảy lên va chạm, hiện UI trả lời câu hỏi.

signal block_activated(game_id: int)

@export var game_id: int = 0
@export var game_name: String = "Game"

var is_cleared: bool = false

func _ready():
	# Kiểm tra trạng thái đã hoàn thành chưa từ ProgressManager
	var current_map_id = GameManager.current_map_id
	is_cleared = ProgressManager.is_game_cleared(current_map_id, game_id)
	
	if has_node("Label"):
		$Label.text = game_name
	
	_update_visuals()

func _update_visuals():
	if is_cleared:
		# Hiển thị trạng thái đã xong (ví dụ: khối gạch rỗng hoặc đổi màu)
		$Sprite2D.texture = load("res://assets/mario_platformer/Empty_Brown_Block.png")
	else:
		$Sprite2D.texture = load("res://assets/mario_platformer/Question_Block.png")

# Hàm được gọi khi Player va chạm (Mario jump hit)
func activate(body):
	if body is CharacterBody2D:
		# Kiểm tra va chạm từ phía dưới
		if body.velocity.y < 100:
			# Vẫn cho hiện panel, nhưng panel sẽ nhận biết là đã xong thông qua GameManager/ProgressManager
			emit_signal("block_activated", game_id)

func mark_as_done():
	is_cleared = true
	_update_visuals()
