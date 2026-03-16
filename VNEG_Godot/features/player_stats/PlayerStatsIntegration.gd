extends Node

# This script integrates the Player Stats feature into the Main Menu at runtime
# without needing to modify MainMenu.tscn or MainMenu.gd.

const STATS_PAGE_PATH = "res://features/player_stats/PlayerStatsPage.tscn"

func _ready():
	# Sử dụng CONNECT_DEFERRED để đảm bảo callback chỉ chạy khi SceneTree đã ổn định
	# Điều này cực kỳ quan trọng để tránh lỗi "Parent node is busy" khi chuyển scene
	get_tree().node_added.connect(_on_node_added, CONNECT_DEFERRED)
	
	# Kiểm tra ngay lập tức nếu đã ở MainMenu
	_check_and_inject.call_deferred(get_tree().current_scene)

func _on_node_added(node: Node):
	# Chỉ xử lý nếu node được thêm vào là MainMenu
	if node.name == "MainMenu":
		_check_and_inject.call_deferred(node)

func _check_and_inject(main_menu: Node):
	if not is_instance_valid(main_menu) or main_menu.name != "MainMenu":
		return
		
	# Tìm DashboardNav
	var nav = main_menu.find_child("DashboardNav", true, false)
	if nav and is_instance_valid(nav) and not nav.has_node("BtnStatistics"):
		var btn = Button.new()
		btn.name = "BtnStatistics"
		btn.text = "Thống kê"
		btn.add_theme_font_size_override("font_size", 16)
		
		# Sử dụng call_deferred để thêm nút một cách an toàn
		nav.add_child.call_deferred(btn)
		
		# Sau khi add xong mới kết nối signal
		btn.ready.connect(func(): 
			btn.pressed.connect(func(): get_tree().change_scene_to_file(STATS_PAGE_PATH))
		)
		
		print("[PlayerStats] Safe injection of Statistics button completed")
