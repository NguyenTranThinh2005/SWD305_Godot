extends Node2D
## VNEG_Godot/scripts/game/InteractiveMap.gd
##
## Quản lý level Mario cho từng Map (Sơ cấp, Trung cấp, Cao cấp).
## Chứa 6 khối gạch đại diện cho 6 Game.

@export var map_id: int = 1
@export var map_name: String = "Map Sơ Cấp"

@onready var blocks_node = $Blocks
@onready var obstacles_node = $Obstacles
@onready var question_panel = $CanvasLayer/MapQuestionPanel
@onready var player = $Player

func _ready():
	map_id = GameManager.current_map_id
	print("Đang tải Interactive Map ID: ", map_id)
	
	# Cập nhật tên Map trong HUD
	var names = {1: "Map Sơ Cấp", 2: "Map Trung Cấp", 3: "Map Cao Cấp"}
	if has_node("CanvasLayer/HUD/MapNameLabel"):
		$CanvasLayer/HUD/MapNameLabel.text = names.get(map_id, "Map " + str(map_id))
	
	# Hiển thị độ khó tương ứng
	_setup_difficulty_layout()
	_setup_background()
	
	# Fetch danh sách game thật từ Backend để lấy ID đúng
	_fetch_real_game_ids()

func _setup_difficulty_layout():
	if !obstacles_node: return
	
	var current_layout_name = "Layout_Map" + str(map_id)
	
	for layout in obstacles_node.get_children():
		var is_active = (layout.name == current_layout_name)
		layout.visible = is_active
		
		# Tắt xử lý và vật lý cho các layout không dùng
		if not is_active:
			layout.process_mode = PROCESS_MODE_DISABLED
		else:
			layout.process_mode = PROCESS_MODE_INHERIT
			print("Đã kích hoạt độ khó: ", layout.name)

func _fetch_real_game_ids():
	var response = await API.get_games_by_map(map_id)
	if response["ok"] and typeof(response["data"]) == TYPE_ARRAY:
		var games = response["data"]
		var block_list = blocks_node.get_children()
		
		# Map theo tên để chính xác loại game
		for g_data in games:
			var g_name = str(g_data.get("name", "")).to_lower()
			var g_id = int(g_data.get("id", 0))
			
			for block in block_list:
				var b_name = block.game_name.to_lower()
				# Nếu tên block (Ngữ pháp, Chính tả...) xuất hiện trong tên game từ Server
				if b_name in g_name or g_name in b_name:
					block.game_id = g_id
					print("Khớp thành công: ", block.game_name, " -> ", g_data.get("name"))
					break
	
	update_blocks()

func _setup_background():
	# Thay đổi background dựa trên map_id
	var bg_sprite = $ParallaxBackground/SkyLayer/Sprite2D
	if !bg_sprite: return
	if map_id == 1:
		bg_sprite.texture = load("res://assets/mario_platformer/Background_0.png")
	elif map_id == 2:
		bg_sprite.texture = load("res://assets/mario_platformer/Background_1.png")
	else:
		# Map 3 hoặc cao hơn
		bg_sprite.texture = load("res://assets/mario_platformer/Polyester2.png")

func update_blocks():
	for block in blocks_node.get_children():
		if block.has_method("_update_visuals"):
			block._update_visuals()

# Hàm callback khi một block được kích hoạt (Mario hit it)
func _on_block_activated(game_id: int):
	print("Map nhận được tín hiệu kích hoạt game: ", game_id)
	# Dừng di chuyển player để tập trung trả lời câu hỏi
	player.set_physics_process(false)
	question_panel.start_quiz(map_id, game_id)
	
	# Đợi cho tới khi panel đóng thì cho player di chuyển tiếp
	if !question_panel.is_connected("hidden", _on_quiz_closed):
		question_panel.hidden.connect(_on_quiz_closed)

func _on_quiz_closed():
	player.set_physics_process(true)
	# Cập nhật lại hình ảnh các khối gạch (nếu vừa mới cleared)
	update_blocks()

func _on_exit_portal_body_entered(body: Node2D) -> void:
	if body == player:
		print("Player chạm vào cổng kết thúc map!")
		if ProgressManager.can_exit_to_next_map(map_id):
			if map_id < 3:
				print("Đủ điều kiện! Chuyển sang Map ", map_id + 1)
				GameManager.current_map_id = map_id + 1
				get_tree().call_deferred("reload_current_scene")
			else:
				print("Đã hoàn thành tất cả các bản đồ!")
				question_panel.show()
				question_panel.get_node("Panel/VBoxMain/QuestionLabel").text = "Chúc mừng! Bạn đã hoàn thành toàn bộ 3 cấp độ (Sơ cấp, Trung cấp, Cao cấp). Bạn là nhà thông thái thực thụ!"
				question_panel.get_node("Panel/CloseButton").show()
		else:
			print("Chưa đủ 6 game cleared (80%).")
			question_panel.show()
			question_panel.get_node("Panel/VBoxMain/QuestionLabel").text = "Bạn cần hoàn thành tất cả 6 khối gạch (>=80%) để mở khóa lối đi sang bản đồ tiếp theo nhé!"
			question_panel.get_node("Panel/CloseButton").show()

func _on_back_button_pressed():
	# Quay về Dashboard chính
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
