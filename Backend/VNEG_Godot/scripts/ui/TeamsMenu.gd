extends Control
## VNEG_Godot/scripts/ui/TeamsMenu.gd
##
## Xử lý giao diện Quản lý Nhóm (Teams) trong Godot.
## Gắn script này vào Node Root của màn hình TeamsMenu.tscn.

@onready var team_list_container: VBoxContainer = $HBox/LeftPanel/ScrollContainer/TeamList
@onready var create_team_name_input: LineEdit = $HBox/RightPanel/CreateBox/NameInput
@onready var create_team_desc_input: LineEdit = $HBox/RightPanel/CreateBox/DescInput
@onready var create_btn: Button = $HBox/RightPanel/CreateBox/CreateButton
@onready var join_code_input: LineEdit = $HBox/RightPanel/JoinBox/CodeInput
@onready var join_btn: Button = $HBox/RightPanel/JoinBox/JoinButton
@onready var status_label: Label = $HBox/RightPanel/StatusLabel

func _ready():
	create_btn.pressed.connect(_on_create_team_pressed)
	join_btn.pressed.connect(_on_join_team_pressed)
	
	# Nút Back về MainMenu
	if has_node("BackButton"):
		$BackButton.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
		
	_load_my_teams()

func _load_my_teams() -> void:
	status_label.text = "Đang tải danh sách nhóm..."
	status_label.add_theme_color_override("font_color", Color.WHITE)
	
	var response = await API.fetch("/api/teams/me")
	
	if response["ok"]:
		status_label.text = ""
		var teams: Array = response["data"]
		
		# Xóa danh sách cũ
		for child in team_list_container.get_children():
			child.queue_free()
			
		if teams.size() == 0:
			var lbl = Label.new()
			lbl.text = "Bạn chưa tham gia nhóm nào."
			team_list_container.add_child(lbl)
			return
			
		for t in teams:
			var panel = PanelContainer.new()
			var vbox = VBoxContainer.new()
			
			var name_lbl = Label.new()
			name_lbl.text = "👥 " + t["name"]
			name_lbl.add_theme_font_size_override("font_size", 18)
			
			var desc_lbl = Label.new()
			desc_lbl.text = t.get("description", "Không có mô tả")
			
			var role_lbl = Label.new()
			var is_owner = (t["ownerId"] == AuthManager.get_user_id())
			role_lbl.text = "Vai trò: " + ("Trưởng nhóm" if is_owner else "Thành viên")
			role_lbl.add_theme_color_override("font_color", Color.GOLD if is_owner else Color.LIGHT_BLUE)
			
			vbox.add_child(name_lbl)
			vbox.add_child(desc_lbl)
			vbox.add_child(role_lbl)
			
			if is_owner:
				var code_lbl = Label.new()
				code_lbl.text = "Code mời: " + t["inviteCode"]
				vbox.add_child(code_lbl)
				
			panel.add_child(vbox)
			team_list_container.add_child(panel)
	else:
		show_status("Lỗi tải danh sách nhóm", Color.RED)

func _on_create_team_pressed() -> void:
	var t_name = create_team_name_input.text.strip_edges()
	var t_desc = create_team_desc_input.text.strip_edges()
	
	if t_name == "":
		show_status("Vui lòng nhập tên nhóm!", Color.RED)
		return
		
	create_btn.disabled = true
	show_status("Đang tạo...", Color.WHITE)
	
	var payload = {
		"name": t_name,
		"description": t_desc
	}
	
	var response = await API.fetch("/api/teams", HTTPClient.METHOD_POST, payload)
	
	create_btn.disabled = false
	if response["ok"]:
		show_status("Tạo nhóm thành công!", Color.GREEN)
		create_team_name_input.text = ""
		create_team_desc_input.text = ""
		_load_my_teams()
	else:
		show_status(str(response["data"]), Color.RED)

func _on_join_team_pressed() -> void:
	var code = join_code_input.text.strip_edges()
	
	if code == "":
		show_status("Vui lòng nhập mã nhóm!", Color.RED)
		return
		
	join_btn.disabled = true
	show_status("Đang tham gia...", Color.WHITE)
	
	var payload = { "inviteCode": code }
	var response = await API.fetch("/api/teams/join", HTTPClient.METHOD_POST, payload)
	
	join_btn.disabled = false
	if response["ok"]:
		show_status("Tham gia thành công!", Color.GREEN)
		join_code_input.text = ""
		_load_my_teams()
	else:
		show_status(str(response["data"]), Color.RED)

func show_status(msg: String, color: Color) -> void:
	status_label.text = msg
	status_label.add_theme_color_override("font_color", color)
