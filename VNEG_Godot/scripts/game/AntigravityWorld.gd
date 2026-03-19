extends Node2D

@onready var ui_canvas: CanvasLayer = $UI
@onready var stars_label: Label = $UI/Control/MarginContainer/TopPanel/TopHUD/StarsLabel
@onready var hp_label: Label = $UI/Control/MarginContainer/TopPanel/TopHUD/HPLabel
@onready var timer_label: Label = $UI/Control/MarginContainer/TopPanel/TopHUD/TimerLabel
@onready var player: CharacterBody2D = $Player
@onready var question_panel: PanelContainer = $UI/Control/QuestionPanel
@onready var choices_panel: PanelContainer = $UI/Control/ChoicesPanel
@onready var pause_menu: ColorRect = $UI/Control/PauseMenu
@onready var pause_btn: Button = $UI/Control/MarginContainer/TopPanel/TopHUD/PauseBtn
@onready var resume_btn: Button = $UI/Control/PauseMenu/CenterContainer/PanelContainer/VBox/ResumeBtn
@onready var retry_btn: Button = $UI/Control/PauseMenu/CenterContainer/PanelContainer/VBox/RetryBtn
@onready var menu_btn: Button = $UI/Control/PauseMenu/CenterContainer/PanelContainer/VBox/MenuBtn

var timer_sec: float = 0.0
var is_game_over: bool = false
var gravity_flipped: bool = false

# Modal overrides
var is_modal_open = false
var active_q_index = 0
var modal_overlay: ColorRect
var modal_panel: PanelContainer
var question_content: VBoxContainer
var header_lbl: Label
var instruction_lbl: Label
var next_btn: Button

func _ready():
	_setup_theme()
	_update_hud()
	
	# Hiding old static panels to let player explore map
	question_panel.hide()
	choices_panel.hide()
	
	_setup_modal_ui()
	_build_level_blocks()
	
	# Connect GameManager signals
	GameManager.hp_changed.connect(func(_hp): _update_hud())
	GameManager.score_changed.connect(func(_s, _c): _update_hud())

	# Pause Logic Connections
	pause_btn.pressed.connect(_toggle_pause)
	resume_btn.pressed.connect(_toggle_pause)
	retry_btn.pressed.connect(_on_pause_retry_pressed)
	menu_btn.pressed.connect(_on_pause_menu_pressed)
	pause_menu.process_mode = PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if not is_game_over and not get_tree().paused:
		timer_sec += delta
		var minutes = int(timer_sec) / 60
		var seconds = int(timer_sec) % 60
		var tenths = int(timer_sec * 10) % 10
		timer_label.text = "%02d.%d:%02d" % [minutes, tenths, seconds]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_game_over:
		_toggle_pause()

func _toggle_pause() -> void:
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	pause_menu.visible = new_pause_state

func _on_pause_retry_pressed() -> void:
	_toggle_pause()
	GameManager.restart_session()
	is_game_over = false
	timer_sec = 0.0
	get_tree().reload_current_scene()

func _on_pause_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _update_hud() -> void:
	stars_label.text = str(GameManager.stars) + " sao"
	var hp_icons = ""
	for i in range(GameManager.max_hp):
		if i < GameManager.hp: hp_icons += "❤️ "
		else: hp_icons += "🖤 "
	hp_label.text = hp_icons.strip_edges()
	if GameManager.hp <= 0: hp_label.text = "💀"

func _setup_theme() -> void:
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color.WHITE
	panel_style.corner_radius_top_left = 20
	panel_style.corner_radius_top_right = 20
	panel_style.corner_radius_bottom_right = 20
	panel_style.corner_radius_bottom_left = 20
	panel_style.border_width_bottom = 6
	panel_style.border_color = Color("#e5e5e5")
	
	$UI/Control/PauseMenu/CenterContainer/PanelContainer.add_theme_stylebox_override("panel", panel_style.duplicate())
	
	stars_label.add_theme_color_override("font_color", Color("#ff9600"))
	timer_label.add_theme_color_override("font_color", Color("#1cb0f6"))
	
	var qb = QuestionBase.new()
	qb.apply_3d_style(pause_btn, Color("#ce82ff"))
	qb.apply_3d_style(resume_btn, Color("#58cc02"))
	qb.apply_3d_style(retry_btn, Color("#ff9600"))
	qb.apply_3d_style(menu_btn, Color("#ff4b4b"))
	qb.queue_free()

# ==========================================
# DYNAMIC BLOCK GENERATION
# ==========================================
func _build_level_blocks() -> void:
	if GameManager.game_questions.size() == 0:
		_show_popup_text("LỖI: Trống câu hỏi!", Color.RED, 1.5)
		return
		
	var start_x = 1000
	var space_x = 700
	
	var i = 0
	for q in GameManager.game_questions:
		var q_type = str(q.get("questionType", "multiple_choice"))
		var title = "Thử thách - C " + str(i + 1)
		
		var y_pos = 500 if (i % 2 == 0) else 150 # Zig zag blocks top and bottom due to gravity flipping
		
		_add_q_block(Vector2(start_x + (i * space_x), y_pos), title, i)
		i += 1
		
	# End flag line
	var end_line = ColorRect.new()
	end_line.color = Color("#58cc02")
	end_line.position = Vector2(start_x + (i * space_x), 0)
	end_line.size = Vector2(20, 1000)
	add_child(end_line)
	
	var end_area = Area2D.new()
	end_area.position = end_line.position + Vector2(10, 300)
	var end_coll = CollisionShape2D.new()
	var end_shape = RectangleShape2D.new()
	end_shape.size = Vector2(100, 1000)
	end_coll.shape = end_shape
	end_area.add_child(end_coll)
	add_child(end_area)
	end_area.body_entered.connect(func(body):
		if body == player and not is_game_over:
			_end_game()
	)

func _add_q_block(pos: Vector2, title: String, q_index: int) -> void:
	var block = StaticBody2D.new()
	block.position = pos
	block.name = "Block_" + str(q_index)
	
	var coll = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(80, 80)
	coll.shape = rect_shape
	block.add_child(coll)
	
	var visual = ColorRect.new()
	visual.name = "Visual"
	visual.color = Color("#fcd000")
	visual.set_anchors_preset(Control.PRESET_CENTER)
	visual.position = Vector2(-40, -40)
	visual.size = Vector2(80, 80)
	
	var q_mark = Label.new()
	q_mark.name = "Label"
	q_mark.text = "?"
	q_mark.add_theme_color_override("font_color", Color("#d96b00"))
	q_mark.add_theme_font_size_override("font_size", 50)
	q_mark.set_anchors_preset(Control.PRESET_FULL_RECT)
	q_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	q_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	visual.add_child(q_mark)
	block.add_child(visual)
	
	var t_lbl = Label.new()
	t_lbl.text = title
	t_lbl.add_theme_color_override("font_color", Color.WHITE)
	t_lbl.add_theme_font_size_override("font_size", 22)
	t_lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
	t_lbl.position = Vector2(-80, -75)
	t_lbl.size = Vector2(160, 30)
	t_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	block.add_child(t_lbl)
	
	var bump_area = Area2D.new()
	bump_area.name = "Area2D"
	bump_area.position = Vector2(0, 0) # Hit anywhere to trigger in antigravity!
	var bump_coll = CollisionShape2D.new()
	bump_coll.name = "CollisionShape2D"
	var bump_shape = RectangleShape2D.new()
	bump_shape.size = Vector2(100, 100) # Slightly bigger to catch easily
	bump_coll.shape = bump_shape
	bump_area.add_child(bump_coll)
	block.add_child(bump_area)
	
	add_child(block)
	
	bump_area.body_entered.connect(func(body):
		if body == player and not is_modal_open and visual.color != Color.DIM_GRAY:
			_hit_block(block, visual, q_mark, q_index)
	)

func _hit_block(block: Node2D, visual: ColorRect, q_mark: Label, q_index: int) -> void:
	is_modal_open = true
	get_tree().paused = true
	
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(visual, "scale", Vector2(1.2, 1.2), 0.1)
	tw.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.1)
	
	_show_question_modal(q_index)

# ==========================================
# MODAL UI CREATION
# ==========================================
func _setup_modal_ui() -> void:
	modal_overlay = ColorRect.new()
	modal_overlay.color = Color(0, 0, 0, 0.7)
	modal_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_overlay.process_mode = Node.PROCESS_MODE_ALWAYS  # FIX Unclickable buttons when paused!
	modal_overlay.hide()
	$UI/Control.add_child(modal_overlay)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_overlay.add_child(center)
	
	modal_panel = PanelContainer.new()
	modal_panel.custom_minimum_size = Vector2(800, 500)
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color.WHITE
	p_style.corner_radius_top_left = 20
	p_style.corner_radius_top_right = 20
	p_style.corner_radius_bottom_right = 20
	p_style.corner_radius_bottom_left = 20
	p_style.border_width_bottom = 6
	p_style.border_color = Color("#e5e5e5")
	modal_panel.add_theme_stylebox_override("panel", p_style)
	center.add_child(modal_panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	modal_panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	header_lbl = Label.new()
	header_lbl.add_theme_font_size_override("font_size", 24)
	header_lbl.add_theme_color_override("font_color", Color("#4b4b4b"))
	header_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header_lbl)
	
	instruction_lbl = Label.new()
	instruction_lbl.add_theme_font_size_override("font_size", 18)
	instruction_lbl.add_theme_color_override("font_color", Color("#ffa500"))
	instruction_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(instruction_lbl)
	
	question_content = VBoxContainer.new()
	question_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(question_content)
	
	var hbox_actions = HBoxContainer.new()
	hbox_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox_actions)
	
	next_btn = Button.new()
	next_btn.text = "Tiếp tục trò chơi"
	next_btn.custom_minimum_size = Vector2(250, 50)
	next_btn.hide()
	var qb = QuestionBase.new()
	qb.apply_3d_style(next_btn, Color("#1cb0f6"))
	qb.queue_free()
	hbox_actions.add_child(next_btn)
	next_btn.pressed.connect(_on_modal_next_pressed)

var _modal_already_submitted = false

func _show_question_modal(q_index: int) -> void:
	_modal_already_submitted = false
	modal_overlay.show()
	active_q_index = q_index
	for c in question_content.get_children(): c.queue_free()
	next_btn.hide()
	
	var q_data = GameManager.game_questions[q_index]
	var q_type = str(q_data.get("questionType", q_data.get("question_type", ""))).to_lower()
	
	header_lbl.text = "Câu %d/%d" % [q_index + 1, GameManager.game_questions.size()]
	header_lbl.add_theme_color_override("font_color", Color("#4b4b4b"))
	instruction_lbl.text = ""
	
	var q_node: QuestionBase = null
	match q_type:
		"find_error":
			q_node = preload("res://scripts/ui/QuestionFindError.gd").new()
			instruction_lbl.text = "Cách chơi: Click vào từ mà bạn nghĩ là sai."
		"picture_guess":
			q_node = preload("res://scripts/ui/QuestionPictureGuess.gd").new()
			instruction_lbl.text = "Cách chơi: Điền đáp án dựa vào ảnh."
		"listen_catch":
			q_node = preload("res://scripts/ui/QuestionListenCatch.gd").new()
		"fill_blank":
			q_node = preload("res://scripts/ui/QuestionFillBlank.gd").new()
		_:
			q_node = preload("res://scripts/ui/QuestionMultipleChoice.gd").new()
			
	if q_node:
		# Add Question Text Label!
		var q_text = _extract_question_text(q_data, q_type)
		if q_text != "":
			var txt_lbl = Label.new()
			txt_lbl.text = q_text
			txt_lbl.add_theme_font_size_override("font_size", 22)
			txt_lbl.add_theme_color_override("font_color", Color("#2b2b2b"))
			txt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			txt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			question_content.add_child(txt_lbl)
			
			var sep = HSeparator.new()
			sep.add_theme_constant_override("separation", 15)
			question_content.add_child(sep)
			
		q_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		q_node.size_flags_vertical = Control.SIZE_EXPAND_FILL
		question_content.add_child(q_node)

		# Make sure buttons inside also run while paused
		q_node.process_mode = Node.PROCESS_MODE_ALWAYS
		
		q_node.setup(q_data)
		q_node.answer_submitted.connect(func(is_correct, raw_ans):
			_on_modal_answer_submitted(q_index, int(q_data.get("id", 0)), is_correct, raw_ans)
		)

# ---------------------------------------------------------------
# EXTRACT QUESTION TEXT 
# ---------------------------------------------------------------
func _extract_question_text(q_data: Dictionary, q_type: String) -> String:
	var raw_data = q_data.get("data", q_data.get("Data", ""))
	if typeof(raw_data) == TYPE_DICTIONARY:
		var q_text = str(raw_data.get("question", ""))
		var hint = str(raw_data.get("hint", ""))
		if hint != "": q_text += "\nGợi ý: " + hint
		return q_text if q_text != "" else str(raw_data)
	raw_data = str(raw_data)
	var json = JSON.new()
	if json.parse(raw_data) == OK:
		var parsed = json.data
		if typeof(parsed) == TYPE_DICTIONARY:
			var q_text = str(parsed.get("question", ""))
			var hint = str(parsed.get("hint", ""))
			if hint != "": q_text += "\nGợi ý: " + hint
			return q_text
	return raw_data

func _on_modal_answer_submitted(q_index: int, q_id: int, is_correct: bool, raw_ans: Variant) -> void:
	if _modal_already_submitted: return
	_modal_already_submitted = true
	
	for child in question_content.get_children():
		if child is Button: child.disabled = true
		
	GameManager.record_answer(q_id, raw_ans, is_correct)
	
	if is_correct:
		# Lật trọng lực VÀ bật Super Jump 
		_trigger_gravity_flip()
		player.call("enable_super_jump") # Thưởng cơ chế nhảy cao
		
		# DISABLE BLOCK ONLY ON CORRECT
		var block = get_node_or_null("Block_" + str(q_index))
		if block:
			block.get_node("Visual").color = Color("#222222")
			block.get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
			block.get_node("Visual/Label").hide()
		
		var reward_txt = "+%d xu" % int(10 * GameManager.combo_multiplier + (GameManager.streak * 2))
		if GameManager.combo_multiplier > 1.0:
			reward_txt = "COMBO %.1fx! %s" % [GameManager.combo_multiplier, reward_txt]
			_show_popup_text(reward_txt, Color(1.0, 0.4, 0.8), 1.2)
		else:
			_show_popup_text(reward_txt, Color(0.3, 1.0, 0.5))
			
		header_lbl.text = "Chính xác!"
		header_lbl.add_theme_color_override("font_color", Color("#58cc02"))
	else:
		_update_hud()
		
		_show_popup_text("Sai rồi! Trừ 1 mạng!", Color(1.0, 0.3, 0.3))
		header_lbl.text = "Sai rồi! Mất 1 mạng!"
		header_lbl.add_theme_color_override("font_color", Color("#ff4b4b"))
		
		var q_data = GameManager.game_questions[q_index]
		var explanation = str(q_data.get("explanation", ""))
		if explanation == "": explanation = "Dap an: " + str(q_data.get("answer", ""))
		var exp_lbl = Label.new()
		exp_lbl.text = explanation
		exp_lbl.add_theme_font_size_override("font_size", 18)
		exp_lbl.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
		exp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		question_content.add_child(exp_lbl)

	next_btn.show()

func _on_modal_next_pressed() -> void:
	if GameManager.hp <= 0:
		_end_game()
		return
		
	modal_overlay.hide()
	get_tree().paused = false
	is_modal_open = false
	
	# Loại bỏ tự động _end_game() khi trả lời xong câu cuối.
	# Phải chạy đến đích chạm màu xanh mới thắng!

# ==========================================
# UTIL & END GAME
# ==========================================
func _trigger_gravity_flip() -> void:
	gravity_flipped = !gravity_flipped
	PhysicsServer2D.area_set_param(
		get_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		Vector2(0, -1 if gravity_flipped else 1)
	)
	if player and player.has_method("flip_gravity"):
		player.flip_gravity(gravity_flipped)

var active_coins: Array = []
func _spawn_coins(_count: int) -> void: pass # Disabled floating coins for Mario mode focus

func _show_popup_text(msg: String, color: Color, scale: float = 1.0) -> void:
	var lbl = Label.new()
	lbl.text = msg
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", int(28 * scale))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(400, 300)
	ui_canvas.add_child(lbl)

	var tween = create_tween()
	tween.set_parallel(true)
	if scale > 1.0:
		lbl.scale = Vector2(0.5, 0.5)
		tween.tween_property(lbl, "scale", Vector2(scale, scale), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(lbl, "position:y", 200.0 if scale > 1.0 else 220.0, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(lbl, "modulate:a", 0.0, 0.8).set_delay(0.5)
	tween.chain().tween_callback(lbl.queue_free)

func _end_game() -> void:
	is_game_over = true
	get_tree().paused = true
	pause_btn.visible = false
	
	modal_overlay.show()
	for child in question_content.get_children():
		child.queue_free()
	
	var accuracy = GameManager.get_accuracy()
	var elapsed = GameManager.get_elapsed_time()
	var time_str = "%d phut %02d giay" % [int(elapsed) / 60, int(elapsed) % 60]

	if GameManager.hp <= 0: header_lbl.text = "HET MANG!"
	elif accuracy >= 80: header_lbl.text = "XUAT SAC!"
	else: header_lbl.text = "KET THUC!"

	var results_box = VBoxContainer.new()
	results_box.alignment = BoxContainer.ALIGNMENT_CENTER
	var stats = [
		["Dung: %d/%d" % [GameManager.correct_count, GameManager.total_answered], Color(0.5, 1.0, 0.5)],
		["Do chinh xac: %.0f%%" % accuracy, Color(0.3, 0.8, 1.0)],
		["Thoi gian: %s" % time_str, Color(1.0, 0.85, 0.0)],
		["Sao: %d" % GameManager.stars, Color(1.0, 0.85, 0.0)]
	]

	for stat in stats:
		var lbl = Label.new()
		lbl.text = stat[0]
		lbl.add_theme_font_size_override("font_size", 20)
		lbl.add_theme_color_override("font_color", stat[1])
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		results_box.add_child(lbl)
	question_content.add_child(results_box)

	var submit_lbl = Label.new()
	submit_lbl.text = "Dang luu ket qua..."
	submit_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question_content.add_child(submit_lbl)

	next_btn.text = " Về Trang Chính "
	next_btn.show()
	next_btn.pressed.disconnect(_on_modal_next_pressed)
	next_btn.pressed.connect(func():
		PhysicsServer2D.area_set_param(get_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0, 1))
		get_tree().paused = false
		GameManager.clear_session()
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)

	if GameManager.current_session_id != 0:
		var answers = GameManager.get_submission_data()
		var res = await API.submit_answers(GameManager.current_session_id, answers)
		if res.has("ok") and res["ok"] and typeof(res["data"]) == TYPE_DICTIONARY:
			submit_lbl.text = "Da luu thanh cong!"
			submit_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		else:
			submit_lbl.text = "Loi khi luu ket qua."
			submit_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	else:
		submit_lbl.text = "Ket qua Offline (Khach)"
