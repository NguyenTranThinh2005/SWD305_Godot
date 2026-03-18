extends Control
## VNEG_Godot/scripts/ui/ProfileMenu.gd
##
## Xử lý giao diện Hồ sơ (Profile) và hiển thị Cây Ngữ Pháp.

@onready var user_info_label: Label = $VBoxContainer/TopPanel/UserInfoLabel
@onready var stats_label: Label = $VBoxContainer/TopPanel/StatsLabel
@onready var grammar_tree_container: VBoxContainer = $VBoxContainer/ScrollContainer/GrammarList
@onready var status_label: Label = $VBoxContainer/TopPanel/StatusLabel

func _ready():
	if has_node("BackButton"):
		$BackButton.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
		
	if AuthManager.is_logged_in():
		var user = AuthManager.current_user
		user_info_label.text = "Hồ sơ: " + user.get("email", "Unknown") + "\nLớp: " + str(user.get("grade", "?")) + " | Vùng: " + user.get("region", "")
	
	_load_grammar_progress()

func _load_grammar_progress() -> void:
	status_label.text = "Đang tải tiến trình học..."
	
	# Gọi 2 API song song: Topcis và Progress
	# Trong GDScript, ta gọi await tuần tự hoặc tự viết cơ chế Promise. Ở đây gọi tuần tự cho dễ hiểu.
	var res_topics = await API.fetch("/api/grammar/topics")
	var res_prog = await API.get_grammar_progress()
	
	if res_topics["ok"] and res_prog["ok"]:
		status_label.text = ""
		
		var topics: Array = res_topics["data"]
		var progress: Array = []
		if res_prog["data"] != null and res_prog["data"].has("progress"):
			progress = res_prog["data"]["progress"]
			
		# Map progress theo Topic ID
		var prog_dict = {}
		for p in progress:
			prog_dict[int(p["grammarTopicId"])] = p
			
		# Xóa UI cũ
		for child in grammar_tree_container.get_children():
			child.queue_free()
			
		# Sinh UI
		for t in topics:
			var panel = PanelContainer.new()
			var vbox = VBoxContainer.new()
			
			var title_lbl = Label.new()
			title_lbl.text = t["name"] + " (" + t.get("code", "") + ")"
			title_lbl.add_theme_font_size_override("font_size", 16)
			
			var p_data = prog_dict.get(int(t["id"]), null)
			var mastery = 0.0
			var info_text = "Chưa học"
			var color = Color.GRAY
			
			if p_data != null:
				mastery = float(p_data.get("masteryLevel", 0.0))
				var correct = int(p_data.get("correct", 0))
				var wrong = int(p_data.get("wrong", 0))
				info_text = "Mức độ: " + str(mastery) + "% | ✅ " + str(correct) + " | ❌ " + str(wrong)
				
				if mastery >= 80: color = Color.GREEN
				elif mastery >= 50: color = Color.YELLOW
				elif mastery > 0: color = Color.ORANGE
				
			var info_lbl = Label.new()
			info_lbl.text = info_text
			info_lbl.add_theme_color_override("font_color", color)
			
			# Thanh tiến trình (ProgressBar)
			var pbar = ProgressBar.new()
			pbar.max_value = 100
			pbar.value = mastery
			pbar.custom_minimum_size = Vector2(0, 10)
			
			vbox.add_child(title_lbl)
			vbox.add_child(info_lbl)
			vbox.add_child(pbar)
			
			panel.add_child(vbox)
			grammar_tree_container.add_child(panel)
			
	else:
		status_label.text = "Lỗi tải dữ liệu ngữ pháp!"
		status_label.add_theme_color_override("font_color", Color.RED)
