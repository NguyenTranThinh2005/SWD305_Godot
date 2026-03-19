extends Control
## VNEG_Godot/scripts/ui/MainMenu.gd
##
## Xử lý giao diện Dashboard & Chọn Màn Chơi.

@onready var welcome_label: Label = $VBoxContainer/HeaderPanel/Header/WelcomeLabel
@onready var score_label: Label = $VBoxContainer/HeaderPanel/Header/ScoreLabel
@onready var map_container: VBoxContainer = $VBoxContainer/MainPanel/HBoxContent/MapContainer/MapScroll/MapList
@onready var games_container: VBoxContainer = $VBoxContainer/MainPanel/HBoxContent/GamesContainer/GameScroll/GameList
@onready var play_button: Button = $VBoxContainer/MainPanel/HBoxContent/GamesContainer/PlayButton

@onready var btn_teams: Button = $VBoxContainer/DashboardNav/BtnTeams
@onready var btn_profile: Button = $VBoxContainer/DashboardNav/BtnProfile

var selected_map_id: int = 0
var selected_game_id: int = 0

func _ready():
	var bg = ColorRect.new()
	bg.color = Color("#f0f4f8")
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)
	
	welcome_label.add_theme_color_override("font_color", Color("#4b4b4b"))
	welcome_label.add_theme_font_size_override("font_size", 28)
	if score_label: score_label.add_theme_color_override("font_color", Color("#ff9600"))

	play_button.pressed.connect(_on_play_pressed)
	if btn_teams: 
		btn_teams.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/TeamsMenu.tscn"))
		_apply_3d_style(btn_teams, Color("#1cb0f6"))
	if btn_profile: 
		btn_profile.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ProfileMenu.tscn"))
		_apply_3d_style(btn_profile, Color("#ce82ff"))
	
	_apply_3d_style(play_button, Color("#58cc02"))
	
	var btn_logout = Button.new()
	btn_logout.text = "Đăng xuất"
	btn_logout.pressed.connect(_on_logout_pressed)
	_apply_3d_style(btn_logout, Color("#ff4b4b"))
	$VBoxContainer/DashboardNav.add_child(btn_logout)
	
	var user_role = AuthManager.get_user_role()
	if user_role == "admin":
		var btn_admin = Button.new()
		btn_admin.text = "⚙️ Admin Panel"
		btn_admin.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/AdminDashboard.tscn"))
		_apply_3d_style(btn_admin, Color("#4b4b4b"))
		$VBoxContainer/DashboardNav.add_child(btn_admin)
	
	if user_role == "admin" or user_role == "staff":
		var btn_staff = Button.new()
		btn_staff.text = "👥 Staff Panel"
		btn_staff.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/StaffPanel.tscn"))
		_apply_3d_style(btn_staff, Color("#ff9600"))
		$VBoxContainer/DashboardNav.add_child(btn_staff)
	
	if AuthManager.is_logged_in():
		var email = AuthManager.current_user.get("email", "Học sinh").split("@")[0]
		welcome_label.text = "Xin chào, " + email + "!"
		_load_user_stats()
	else:
		get_tree().change_scene_to_file("res://scenes/LoginScreen.tscn")
		return
		
	_load_maps()

func _load_user_stats() -> void:
	# Gọi API lấy Grammar Progress hiển thị hoặc tổng sao (Mock logic)
	pass

func _load_maps() -> void:
	for child in map_container.get_children():
		if child.name != "Label":
			child.queue_free()
			
	var lbl = Label.new()
	lbl.text = "Đang tải dữ liệu Maps..."
	map_container.add_child(lbl)
			
	var response = await API.get_maps()
	lbl.queue_free()
	
	if response["ok"] and typeof(response["data"]) == TYPE_ARRAY:
		var maps = response["data"]
		for m_data in maps:
			var btn = Button.new()
			btn.text = "🌍 " + str(m_data.get("name", "Map"))
			var m_id = int(m_data.get("id", 0))
			btn.pressed.connect(func(): _on_map_selected(m_id, m_data.get("name", "Map")))
			_apply_3d_style(btn, Color("#2b7489"))
			map_container.add_child(btn)
	else:
		var err = Label.new()
		err.text = "Lỗi tải Map từ Server!"
		map_container.add_child(err)

func _on_map_selected(map_id: int, map_name: String) -> void:
	selected_map_id = map_id
	selected_game_id = 0
	play_button.disabled = true
	print("Đã chọn Map ID: ", map_id, " - ", map_name)
	
	for child in games_container.get_children():
		if child.name != "Label" and child != play_button:
			child.queue_free()
			
	var lbl = Label.new()
	lbl.text = "Đang tải danh sách Game..."
	games_container.add_child(lbl)
	games_container.move_child(lbl, games_container.get_child_count() - 2)
			
	var response = await API.get_games_by_map(map_id)
	lbl.queue_free()
	
	if response["ok"] and typeof(response["data"]) == TYPE_ARRAY:
		var games = response["data"]
		if games.size() == 0:
			var no_game = Label.new()
			no_game.text = "Map này chưa có Game nào."
			games_container.add_child(no_game)
			games_container.move_child(no_game, games_container.get_child_count() - 2)
			return
			
		for g_data in games:
			var btn = Button.new()
			btn.text = "🎮 " + str(g_data.get("name", "Game"))
			var g_id = int(g_data.get("id", 0))
			btn.pressed.connect(func(): _on_game_selected(g_id, g_data.get("name", "Game")))
			_apply_3d_style(btn, Color("#1cb0f6"))
			games_container.add_child(btn)
			games_container.move_child(btn, games_container.get_child_count() - 2)
	else:
		var err = Label.new()
		err.text = "Lỗi tải Game từ Server!"
		games_container.add_child(err)
		games_container.move_child(err, games_container.get_child_count() - 2)

func _on_game_selected(game_id: int, game_name: String) -> void:
	selected_game_id = game_id
	play_button.disabled = false
	print("Đã chọn Game ID: ", game_id, " - ", game_name)

func _on_play_pressed() -> void:
	if selected_game_id == 0:
		return
		
	print("Bắt đầu khởi tạo Session cho Game ID: ", selected_game_id)
	play_button.disabled = true
	play_button.text = "Đang khởi tạo game..."
	
	var user_id = int(AuthManager.current_user.get("id", 0))
	
	# GUEST MODE: Skip start_game (no DB session)
	if user_id == 0:
		play_button.text = "Dang tai cau hoi (Khach)..."
		var q_res = await API.get_questions_by_game(selected_game_id)
		if q_res["ok"] and typeof(q_res["data"]) == TYPE_ARRAY:
			GameManager.start_session(0, selected_game_id) # Session 0 = Guest
			GameManager.game_questions = q_res["data"]
			get_tree().change_scene_to_file("res://scenes/AntigravityWorld.tscn")
		else:
			play_button.text = "Loi tai cau hoi Khach!"
			await get_tree().create_timer(2.0).timeout
			play_button.disabled = false
			play_button.text = "Choi game nay"
		return

	# REGULAR USER MODE: Create server session
	var start_response = await API.start_game(user_id, selected_game_id)
	
	if start_response["ok"] and typeof(start_response["data"]) == TYPE_DICTIONARY:
		var session_id = int(start_response["data"].get("sessionId", 0))
		GameManager.start_session(session_id, selected_game_id)
		
		# Now fetch questions for this session
		play_button.text = "Dang tải cau hoi..."
		var q_response = await API.get_questions(session_id)
		
		if q_response["ok"] and typeof(q_response["data"]) == TYPE_ARRAY:
			var q_list = q_response["data"]
			if q_list.size() > 0:
				GameManager.game_questions = q_list
				get_tree().change_scene_to_file("res://scenes/AntigravityWorld.tscn")
			else:
				play_button.text = "Game nay khong co cau hoi!"
				await get_tree().create_timer(2.0).timeout
				play_button.disabled = false
				play_button.text = "Choi game nay"
		else:
			play_button.text = "Loi tai cau hoi!"
			await get_tree().create_timer(2.0).timeout
			play_button.disabled = false
			play_button.text = "Choi game nay"
	else:
		play_button.text = "Loi khoi tao Session!"
		await get_tree().create_timer(2.0).timeout
		play_button.disabled = false
		play_button.text = "Choi game nay"


func _on_logout_pressed() -> void:
	if AuthManager.get_token() == "GUEST_TOKEN":
		AuthManager.clear_session()
	else:
		await API.logout() # Wait for session cleanup
		
	get_tree().change_scene_to_file("res://scenes/LoginScreen.tscn")

func _apply_3d_style(btn: Button, base_color: Color) -> void:
	btn.custom_minimum_size = Vector2(0, 60)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	btn.add_theme_color_override("font_focus_color", Color.WHITE)
	
	var style = StyleBoxFlat.new()
	style.bg_color = base_color
	style.border_width_bottom = 6
	style.border_color = base_color.darkened(0.2)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_right = 16
	style.corner_radius_bottom_left = 16
	
	btn.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = base_color.lightened(0.1)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = style.duplicate()
	pressed_style.border_width_bottom = 0
	pressed_style.content_margin_top = 6
	btn.add_theme_stylebox_override("pressed", pressed_style)
