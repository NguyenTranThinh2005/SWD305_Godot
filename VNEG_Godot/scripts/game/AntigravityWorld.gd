extends Node2D
## AntigravityWorld.gd — Game Loop chính
## Quản lý: hiển thị câu hỏi, tính điểm, gravity flip, API submit

@onready var ui_canvas: CanvasLayer = $UI
@onready var question_label: Label = $UI/Control/QuestionPanel/QuestionBox/QuestionLabel
@onready var choices_box: VBoxContainer = $UI/Control/ChoicesPanel/ChoicesBox
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
var current_question_index: int = 0
var is_game_over: bool = false
var is_transitioning: bool = false
var gravity_flipped: bool = false

func _ready():
	_setup_theme()
	_update_hud()
	# Connect GameManager signals
	GameManager.hp_changed.connect(func(_hp): _update_hud())
	GameManager.score_changed.connect(func(_s, _c): _update_hud())

	if GameManager.game_questions.size() > 0:
		_show_question(0)
	else:
		question_label.text = "Không tìm thấy câu hỏi!"

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
	current_question_index = 0
	is_game_over = false
	timer_sec = 0.0
	_update_hud()
	_show_question(0)

func _on_pause_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _update_hud() -> void:
	stars_label.text = str(GameManager.stars) + " sao"
	var hp_icons = ""
	for i in range(GameManager.max_hp):
		if i < GameManager.hp:
			hp_icons += "❤️ "
		else:
			hp_icons += "🖤 "
	hp_label.text = hp_icons.strip_edges()
	if GameManager.hp <= 0:
		hp_label.text = "💀"

func _setup_theme() -> void:
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color.WHITE
	panel_style.corner_radius_top_left = 20
	panel_style.corner_radius_top_right = 20
	panel_style.corner_radius_bottom_right = 20
	panel_style.corner_radius_bottom_left = 20
	panel_style.border_width_bottom = 6
	panel_style.border_color = Color("#e5e5e5")
	
	question_panel.add_theme_stylebox_override("panel", panel_style)
	choices_panel.add_theme_stylebox_override("panel", panel_style.duplicate())
	$UI/Control/PauseMenu/CenterContainer/PanelContainer.add_theme_stylebox_override("panel", panel_style.duplicate())
	
	# Force QuestionPanel down to prevent HUD overlap (overrides scene settings)
	question_panel.offset_top = 100.0
	question_panel.offset_bottom = 200.0
	
	question_label.add_theme_color_override("font_color", Color("#4b4b4b"))
	stars_label.add_theme_color_override("font_color", Color("#ff9600"))
	timer_label.add_theme_color_override("font_color", Color("#1cb0f6"))
	
	_apply_3d_style(pause_btn, Color("#ce82ff"))
	_apply_3d_style(resume_btn, Color("#58cc02"))
	_apply_3d_style(retry_btn, Color("#ff9600"))
	_apply_3d_style(menu_btn, Color("#ff4b4b"))

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

# ---------------------------------------------------------------
# EXTRACT QUESTION TEXT — hoc JSON từ Backend
# ---------------------------------------------------------------
func _extract_question_text(q_data: Dictionary, q_type: String) -> String:
	var raw_data = q_data.get("data", q_data.get("Data", ""))
	if typeof(raw_data) == TYPE_DICTIONARY:
		# Return directly if already parsed
		var q_text = str(raw_data.get("question", ""))
		var hint = str(raw_data.get("hint", ""))
		if hint != "": q_text += "\nGợi ý: " + hint
		return q_text if q_text != "" else str(raw_data)
	
	raw_data = str(raw_data)

	var json = JSON.new()
	if json.parse(raw_data) == OK:
		var parsed = json.data
		# JSON object: {"question":"...", "options":[...], "hint":"..."}
		if typeof(parsed) == TYPE_DICTIONARY:
			var q_text = str(parsed.get("question", ""))
			var hint = str(parsed.get("hint", ""))
			if hint != "":
				q_text += "\nGoi y: " + hint
			return q_text
		# JSON array: ["word1", "word2", ...]
		if typeof(parsed) == TYPE_ARRAY:
			var words = []
			for item in parsed:
				words.append(str(item))
			if q_type == "find_error":
				return " ".join(words)
			else:
				return " / ".join(words)

	var explanation = str(q_data.get("explanation", ""))
	if explanation != "":
		return explanation
	return raw_data

# ---------------------------------------------------------------
# SHOW QUESTION — with fade transition
# ---------------------------------------------------------------
func _show_question(index: int) -> void:
	if index >= GameManager.game_questions.size():
		_end_game()
		return

	is_transitioning = true

	# Fade out old content (skip for first question)
	if index > 0:
		var fade_out = create_tween()
		fade_out.tween_property(choices_panel, "modulate:a", 0.0, 0.1)
		await fade_out.finished

	# Ensure panel is fully visible for new question
	choices_panel.modulate.a = 1.0

	# Clear old UI
	for child in choices_box.get_children():
		child.queue_free()

	# Spawn coins 
	_spawn_coins(randi_range(1, 4))

	var q_data = GameManager.game_questions[index]
	# Robust key access (PascalCase support)
	var q_type = str(q_data.get("questionType", q_data.get("question_type", q_data.get("QuestionType", "")))).to_lower()

	# Build display text
	var display_text = _extract_question_text(q_data, q_type)
	var q_num = index + 1
	var q_total = GameManager.game_questions.size()
	question_label.text = "Câu " + str(q_num) + "/" + str(q_total) + "\n" + display_text

	# Determine which Question UI to use
	var q_node: QuestionBase = null
	match q_type:
		"multiple_choice", "grammar", "image_choice", "image_sentence", "":
			q_node = preload("res://scripts/ui/QuestionMultipleChoice.gd").new()
		"fill_blank":
			q_node = preload("res://scripts/ui/QuestionFillBlank.gd").new()
		"listen_choose":
			q_node = preload("res://scripts/ui/QuestionListenChoose.gd").new()
		"listen_catch":
			q_node = preload("res://scripts/ui/QuestionListenCatch.gd").new()
		"rhythm_reading":
			q_node = preload("res://scripts/ui/QuestionRhythmReading.gd").new()
		"find_error":
			q_node = preload("res://scripts/ui/QuestionFindError.gd").new()
		"picture_guess":
			q_node = preload("res://scripts/ui/QuestionPictureGuess.gd").new()
		"drag_drop_sentence":
			q_node = preload("res://scripts/ui/QuestionDragDropSentence.gd").new()
		_:
			q_node = preload("res://scripts/ui/QuestionMultipleChoice.gd").new()

	if q_node:
		q_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		q_node.size_flags_vertical = Control.SIZE_EXPAND_FILL
		q_node.custom_minimum_size = Vector2(0, 240) # Ensure visibility
		choices_box.add_child(q_node)
		q_node.setup(q_data)
		q_node.answer_submitted.connect(func(is_correct, raw_ans):
			_on_answer_submitted(index, q_data.get("id", q_data.get("Id", 0)), is_correct, raw_ans)
		)

	is_transitioning = false
	choices_panel.modulate.a = 1.0

func _on_answer_submitted(_q_index: int, q_id: int, is_correct: bool, raw_ans: Variant) -> void:
	if is_game_over or is_transitioning: return

	# Disable all interactive elements
	for child in choices_box.get_children():
		if child is Button:
			child.disabled = true

	var q_data = GameManager.game_questions[_q_index]
	var real_q_id = int(q_data.get("id", 0))
	GameManager.record_answer(real_q_id, raw_ans, is_correct)

	if is_correct:
		_trigger_gravity_flip()
		var reward_txt = "+%d xu" % int(10 * GameManager.combo_multiplier + (GameManager.streak * 2))
		if GameManager.combo_multiplier > 1.0:
			reward_txt = "COMBO %.1fx! %s" % [GameManager.combo_multiplier, reward_txt]
			_show_popup_text(reward_txt, Color(1.0, 0.4, 0.8), 1.2) # Bright pink for combos
		else:
			_show_popup_text(reward_txt, Color(0.3, 1.0, 0.5))
	else:
		_show_popup_text("Sai roi!", Color(1.0, 0.3, 0.3))

	# Show correct answer explanation briefly
	var explanation = str(q_data.get("explanation", ""))
	if explanation != "" and not is_correct:
		var exp_lbl = Label.new()
		exp_lbl.text = "Dap an: " + str(q_data.get("answer", ""))
		exp_lbl.add_theme_font_size_override("font_size", 18)
		exp_lbl.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
		exp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		choices_box.add_child(exp_lbl)

	if GameManager.hp <= 0:
		await get_tree().create_timer(1.2).timeout
		_end_game()
		return

	# Wait before next question (let player see feedback)
	await get_tree().create_timer(1.5).timeout
	current_question_index += 1
	_show_question(current_question_index)

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

func _spawn_coins(count: int) -> void:
	for c in active_coins:
		if is_instance_valid(c): c.queue_free()
	active_coins.clear()

	var spawn_rect = Rect2(150, 200, 850, 250)

	for i in range(count):
		var coin = Area2D.new()
		coin.set_script(preload("res://scripts/game/FloatingCoin.gd"))
		coin.position = Vector2(
			randf_range(spawn_rect.position.x, spawn_rect.end.x),
			randf_range(spawn_rect.position.y, spawn_rect.end.y)
		)
		add_child(coin)
		coin.coin_collected.connect(func(bonus):
			GameManager.stars += bonus
			_update_hud()
			_show_popup_text("+1 sao", Color(1.0, 0.85, 0.0))
		)
		active_coins.append(coin)

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

# ---------------------------------------------------------------
# END GAME — Results screen
# ---------------------------------------------------------------
func _end_game() -> void:
	is_game_over = true
	pause_btn.visible = false

	# Clean up coins
	for c in active_coins:
		if is_instance_valid(c): c.queue_free()
	active_coins.clear()

	# Clear question UI
	for child in choices_box.get_children():
		child.queue_free()

	# Determine result
	var accuracy = GameManager.get_accuracy()
	var elapsed = GameManager.get_elapsed_time()
	var minutes = int(elapsed) / 60
	var seconds = int(elapsed) % 60
	var time_str = "%d phut %02d giay" % [minutes, seconds]

	var result_header = ""
	if GameManager.hp <= 0:
		result_header = "HET MANG!"
	elif accuracy >= 80:
		result_header = "XUAT SAC!"
	elif accuracy >= 50:
		result_header = "KHONG TE!"
	else:
		result_header = "KET THUC!"

	question_label.text = result_header

	# Build results panel
	var results_box = VBoxContainer.new()
	results_box.alignment = BoxContainer.ALIGNMENT_CENTER
	results_box.add_theme_constant_override("separation", 8)

	var stats = [
		["Dung: %d/%d" % [GameManager.correct_count, GameManager.total_answered], Color(0.5, 1.0, 0.5)],
		["Do chinh xac: %.0f%%" % accuracy, Color(0.3, 0.8, 1.0)],
		["Thoi gian: %s" % time_str, Color(1.0, 0.85, 0.0)],
		["Sao: %d" % GameManager.stars, Color(1.0, 0.85, 0.0)],
		["Xu: %d" % GameManager.coins, Color(1.0, 0.7, 0.2)],
		["Chuoi dai nhat: %d" % GameManager.max_streak, Color(0.8, 0.5, 1.0)],
	]

	for stat in stats:
		var lbl = Label.new()
		lbl.text = stat[0]
		lbl.add_theme_font_size_override("font_size", 20)
		lbl.add_theme_color_override("font_color", stat[1])
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		results_box.add_child(lbl)

	choices_box.add_child(results_box)

	# Submitting label
	var submit_lbl = Label.new()
	submit_lbl.text = "Dang luu ket qua..."
	submit_lbl.add_theme_font_size_override("font_size", 16)
	submit_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	submit_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	choices_box.add_child(submit_lbl)

	# Buttons HBox
	var btn_hbox = HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hbox.add_theme_constant_override("separation", 20)
	choices_box.add_child(btn_hbox)

	# Retry button
	var btn_retry = Button.new()
	btn_retry.text = " Choi Lai "
	btn_retry.add_theme_font_size_override("font_size", 22)
	btn_retry.custom_minimum_size = Vector2(160, 55)
	btn_hbox.add_child(btn_retry)
	btn_retry.pressed.connect(func():
		GameManager.restart_session()
		current_question_index = 0
		is_game_over = false
		timer_sec = 0.0
		_update_hud()
		_show_question(0)
	)
	_apply_3d_style(btn_retry, Color("#ff9600"))

	# Exit button
	var btn_exit = Button.new()
	btn_exit.text = " Về Trang Chính "
	btn_exit.add_theme_font_size_override("font_size", 22)
	btn_exit.custom_minimum_size = Vector2(200, 60)
	btn_hbox.add_child(btn_exit)
	_apply_3d_style(btn_exit, Color("#4b4b4b"))

	# Submit to backend (Skip for GUEST)
	if GameManager.current_session_id != 0:
		var answers = GameManager.get_submission_data()
		var res = await API.submit_answers(GameManager.current_session_id, answers)

		if GameManager.current_task_id != 0:
			await API.complete_team_task(GameManager.current_task_id, GameManager.current_session_id)

		if res.has("ok") and res["ok"] and typeof(res["data"]) == TYPE_DICTIONARY:
			submit_lbl.text = "Da luu thanh cong!"
			submit_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		else:
			submit_lbl.text = "Loi khi luu ket qua."
			submit_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	else:
		submit_lbl.text = "Ket qua Offline (Khach)"
		submit_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))


	btn_exit.disabled = false
	btn_exit.pressed.connect(func():
		PhysicsServer2D.area_set_param(
			get_world_2d().space,
			PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
			Vector2(0, 1)
		)
		GameManager.clear_session()
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)
