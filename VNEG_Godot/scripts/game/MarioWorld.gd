extends Node2D

@onready var ui_canvas = $UI
@onready var modal_overlay = $UI/Control/ModalOverlay
@onready var question_content = $UI/Control/ModalOverlay/CenterContainer/PanelContainer/Margin/VBox/QuestionContent
@onready var header_lbl = $UI/Control/ModalOverlay/CenterContainer/PanelContainer/Margin/VBox/HeaderLbl
@onready var instruction_lbl = $UI/Control/ModalOverlay/CenterContainer/PanelContainer/Margin/VBox/InstructionLbl
@onready var next_btn = $UI/Control/ModalOverlay/CenterContainer/PanelContainer/Margin/VBox/HBoxActions/NextBtn
@onready var stars_lbl = $UI/Control/HUD/HBox/StarsLbl
@onready var exit_btn = $UI/Control/HUD/HBox/ExitBtn
@onready var player = $Player

var current_session_questions = []
var active_q_index = 0
var active_block = null
var is_modal_open = false

func _ready() -> void:
	_setup_theme()
	_build_level()
	
	exit_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
	next_btn.pressed.connect(_on_next_pressed)
	next_btn.hide()
	
	GameManager.stars = 0
	stars_lbl.text = "⭐ 0"

func _build_level():
	_add_q_block(Vector2(600, 400), "find_error", "Chính tả")
	_add_q_block(Vector2(1100, 300), "random", "Ôn tập")
	_add_q_block(Vector2(1700, 400), "picture_guess", "Đoán hình")
	_add_q_block(Vector2(2400, 250), "listen_choose", "Nghe hiểu")
	_add_q_block(Vector2(3200, 300), "grammar", "Ngữ pháp")

func _add_q_block(pos: Vector2, q_type: String, title: String):
	var block = StaticBody2D.new()
	block.position = pos
	
	# Collision for standing on top / sides
	var coll = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(60, 60)
	coll.shape = rect_shape
	block.add_child(coll)
	
	# Visual Box
	var visual = ColorRect.new()
	visual.color = Color("#fcd000") # Yellow/Gold
	visual.set_anchors_preset(Control.PRESET_CENTER)
	visual.position = Vector2(-30, -30) # Center the rect
	visual.size = Vector2(60, 60)
	
	var q_mark = Label.new()
	q_mark.text = "?"
	q_mark.add_theme_color_override("font_color", Color("#d96b00"))
	q_mark.add_theme_font_size_override("font_size", 40)
	q_mark.set_anchors_preset(Control.PRESET_FULL_RECT)
	q_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	q_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	visual.add_child(q_mark)
	block.add_child(visual)
	
	# Title Label above block
	var t_lbl = Label.new()
	t_lbl.text = title
	t_lbl.add_theme_color_override("font_color", Color.WHITE)
	t_lbl.add_theme_font_size_override("font_size", 20)
	t_lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
	t_lbl.position = Vector2(-80, -65)
	t_lbl.size = Vector2(160, 30)
	t_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	block.add_child(t_lbl)
	
	# Bottom Bump Sensor
	var bump_area = Area2D.new()
	bump_area.position = Vector2(0, 32) # Just below block
	var bump_coll = CollisionShape2D.new()
	var bump_shape = RectangleShape2D.new()
	bump_shape.size = Vector2(50, 10)
	bump_coll.shape = bump_shape
	bump_area.add_child(bump_coll)
	block.add_child(bump_area)
	
	$LevelGeometry.add_child(block)
	
	# Connect signal dynamically
	bump_area.body_entered.connect(func(body):
		if body == player and body.velocity.y < 0 and not is_modal_open and visual.color != Color.DIM_GRAY:
			_hit_block(block, visual, q_mark, q_type)
	)

func _hit_block(block: Node2D, visual: ColorRect, q_mark: Label, q_type: String):
	is_modal_open = true
	get_tree().paused = true # Pause physics
	
	# Bounce anim (runs even when paused)
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(visual, "position:y", -45.0, 0.1)
	tw.tween_property(visual, "position:y", -30.0, 0.1)
	
	# Disable block visually
	visual.color = Color.DIM_GRAY
	q_mark.text = ""
	
	# Open UI
	modal_overlay.show()
	header_lbl.text = "Đang tải câu hỏi..."
	header_lbl.add_theme_color_override("font_color", Color("#4b4b4b"))
	instruction_lbl.text = ""
	next_btn.hide()
	
	active_block = block
	
	# Fetch Questions via API
	var session_id = GameManager.current_session_id
	if session_id <= 0: session_id = 999 
		
	var url = "http://localhost:5033/api/game/%d/questions?type=%s&limit=3" % [session_id, q_type]
	
	var http = HTTPRequest.new()
	add_child(http)
	http.process_mode = Node.PROCESS_MODE_ALWAYS
	http.request_completed.connect(func(_res, code, _headers, body):
		http.queue_free()
		if code == 200:
			var body_str = body.get_string_from_utf8()
			if body_str != "":
				var json = JSON.parse_string(body_str)
				if json is Array and json.size() > 0:
					current_session_questions = json
					active_q_index = 0
					_show_question_modal()
					return
		
		# Fallback
		_show_modal_error("Gạch này chưa có dữ liệu online! Đang dùng Mock.")
		await get_tree().create_timer(1.0).timeout
		_mock_load(q_type)
	)
	if GameManager.current_session_id > 0:
		http.request(url)
	else:
		http.queue_free()
		_mock_load(q_type)

func _mock_load(q_type):
	var mock_q = {
		"id": -1, "questionType": q_type, "answer": "1",
		"data": "{\"question\":\"[MOCK] Thử thách cho \" + q_type, \"options\":[\"1\", \"2\"]}"
	}
	current_session_questions = [mock_q]
	active_q_index = 0
	_show_question_modal()

func _show_question_modal():
	if active_q_index >= current_session_questions.size():
		_finish_block_session()
		return
		
	for c in question_content.get_children():
		c.queue_free()
		
	next_btn.hide()
	instruction_lbl.text = ""
	header_lbl.text = "Câu %d/%d" % [active_q_index + 1, current_session_questions.size()]
	header_lbl.add_theme_color_override("font_color", Color("#4b4b4b"))
	
	var q_data = current_session_questions[active_q_index]
	var raw_type = str(q_data.get("questionType", "multiple_choice"))
	
	var q_node: QuestionBase = null
	match raw_type:
		"find_error":
			q_node = preload("res://scripts/ui/QuestionFindError.gd").new()
			instruction_lbl.text = "Cách chơi: Click vào từ mà bạn nghĩ là sai."
		"picture_guess":
			q_node = preload("res://scripts/ui/QuestionPictureGuess.gd").new()
			instruction_lbl.text = "Cách chơi: Điền tên sự vật trong ảnh."
		"listen_catch":
			q_node = preload("res://scripts/ui/QuestionListenCatch.gd").new()
		"fill_blank":
			q_node = preload("res://scripts/ui/QuestionFillBlank.gd").new()
		"drag_drop_sentence":
			q_node = preload("res://scripts/ui/QuestionDragDropSentence.gd").new()
			instruction_lbl.text = "Cách chơi: Sắp xếp các từ thành câu hoàn chỉnh."
		"listen_choose":
			q_node = preload("res://scripts/ui/QuestionListenChoose.gd").new()
			instruction_lbl.text = "Cách chơi: Lắng nghe và chọn đáp án chính xác."
		"rhythm_reading":
			q_node = preload("res://scripts/ui/QuestionRhythmReading.gd").new()
			instruction_lbl.text = "Cách chơi: Đọc theo nhịp điệu bài hát."
		_:
			q_node = preload("res://scripts/ui/QuestionMultipleChoice.gd").new()
			
	if q_node:
		q_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		q_node.size_flags_vertical = Control.SIZE_EXPAND_FILL
		question_content.add_child(q_node)
		q_node.setup(q_data)
		q_node.process_mode = Node.PROCESS_MODE_ALWAYS # run when paused
		q_node.answer_submitted.connect(_on_answer_submitted)

func _on_answer_submitted(is_correct: bool, _raw_ans):
	next_btn.text = "Tiếp theo"
	next_btn.show()
	if is_correct:
		GameManager.stars += 1
		stars_lbl.text = "⭐ %d" % GameManager.stars
		header_lbl.text = "Chính xác!"
		header_lbl.add_theme_color_override("font_color", Color("#58cc02"))
	else:
		header_lbl.text = "Sai rồi!"
		header_lbl.add_theme_color_override("font_color", Color("#ff4b4b"))

func _on_next_pressed():
	active_q_index += 1
	_show_question_modal()
	
func _finish_block_session():
	for c in question_content.get_children(): c.queue_free()
	next_btn.hide()
	instruction_lbl.text = ""
	header_lbl.text = ""
	
	var msg = Label.new()
	msg.text = "Hoàn thành thử thách gạch này!\nTiếp tục di chuyển và đụng khối khác nhé."
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.add_theme_color_override("font_color", Color("#4b4b4b"))
	msg.add_theme_font_size_override("font_size", 24)
	question_content.add_child(msg)
	
	var close_btn = Button.new()
	close_btn.text = "Tiếp tục trọn vẹn màn chơi"
	close_btn.custom_minimum_size = Vector2(300, 55)
	
	# Instantiate dummy base to borrow style functions
	var qb = QuestionBase.new()
	qb.apply_3d_style(close_btn, Color("#1cb0f6"))
	question_content.add_child(close_btn)
	qb.queue_free()
	
	close_btn.pressed.connect(func():
		modal_overlay.hide()
		get_tree().paused = false
		is_modal_open = false
	)

func _show_modal_error(msg: String):
	header_lbl.text = "Thông báo"
	for c in question_content.get_children(): c.queue_free()
	var l = Label.new()
	l.text = msg
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_color", Color("#4b4b4b"))
	question_content.add_child(l)
	next_btn.text = "Bỏ qua & Chơi nháp"
	next_btn.show()

func _setup_theme():
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color.WHITE
	panel_style.corner_radius_top_left = 20
	panel_style.corner_radius_top_right = 20
	panel_style.corner_radius_bottom_right = 20
	panel_style.corner_radius_bottom_left = 20
	panel_style.border_width_bottom = 6
	panel_style.border_color = Color("#e5e5e5")
	$UI/Control/ModalOverlay/CenterContainer/PanelContainer.add_theme_stylebox_override("panel", panel_style)
	
	var qb = QuestionBase.new()
	qb.apply_3d_style(next_btn, Color("#58cc02"))
	qb.apply_3d_style(exit_btn, Color("#ff4b4b"))
	qb.queue_free()
