extends QuestionBase
## QuestionDragDropSentence.gd — Xep tu thanh cau

var word_bank: HFlowContainer
var target_zone: HFlowContainer
var submit_btn: Button

func _do_setup() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 12)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var instr = Label.new()
	instr.text = "Bam vao cac tu theo dung thu tu de ghep cau:"
	instr.add_theme_font_size_override("font_size", 16)
	instr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instr.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	instr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(instr)

	# Target Zone — shows sentence being built
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 55)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.08, 0.12, 0.8)
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.42, 0.39, 1.0, 0.7)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.content_margin_left = 10
	panel_style.content_margin_right = 10
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", panel_style)

	target_zone = HFlowContainer.new()
	target_zone.name = "TargetZone"
	target_zone.custom_minimum_size = Vector2(0, 40)
	target_zone.alignment = FlowContainer.ALIGNMENT_CENTER
	target_zone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	target_zone.add_theme_constant_override("h_separation", 6)
	panel.add_child(target_zone)
	add_child(panel)

	# Word Bank
	word_bank = HFlowContainer.new()
	word_bank.name = "WordBank"
	word_bank.custom_minimum_size = Vector2(0, 50)
	word_bank.alignment = FlowContainer.ALIGNMENT_CENTER
	word_bank.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_bank.add_theme_constant_override("h_separation", 6)
	word_bank.add_theme_constant_override("v_separation", 6)
	add_child(word_bank)

	submit_btn = Button.new()
	submit_btn.text = "Xac nhan"
	submit_btn.custom_minimum_size = Vector2(200, 48)
	apply_3d_style(submit_btn, Color("#1cb0f6"))
	add_child(submit_btn)
	submit_btn.pressed.connect(_on_submit_pressed)

	_setup_words()

func _setup_words() -> void:
	var raw = question_data.get("data", question_data.get("Data", ""))
	var words = []
	var data_dict = null
	
	if typeof(raw) == TYPE_ARRAY:
		words = raw
	elif typeof(raw) == TYPE_DICTIONARY:
		data_dict = raw
	elif typeof(raw) == TYPE_STRING and raw != "":
		var json = JSON.new()
		if json.parse(raw) == OK:
			if typeof(json.data) == TYPE_ARRAY:
				words = json.data
			elif typeof(json.data) == TYPE_DICTIONARY:
				data_dict = json.data
	
	if data_dict != null:
		var w = data_dict.get("words", data_dict.get("Words", data_dict.get("options", [])))
		if typeof(w) == TYPE_ARRAY: words = w
			
	if words.size() == 0 and typeof(raw) == TYPE_STRING:
		words = raw.replace("[", "").replace("]", "").replace("\"", "").split(",")

	var correct_sentence = str(question_data.get("answer", question_data.get("Answer", ""))).strip_edges()

	var shuffled = []
	for w in words:
		var text = str(w).strip_edges()
		if text != "": shuffled.append(text)
	shuffled.shuffle()

	for w_text in shuffled:
		var btn = _create_word_btn(w_text, Color(0.42, 0.39, 1.0, 1))
		word_bank.add_child(btn)
		btn.pressed.connect(func(): _move_word_to_target(btn, w_text))

func _create_word_btn(text: String, accent_color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	apply_3d_style(btn, accent_color)
	return btn

func _move_word_to_target(btn: Button, w_text: String) -> void:
	if btn.get_parent() == word_bank:
		word_bank.remove_child(btn)
		target_zone.add_child(btn)
		# Restyle for target zone (green)
		apply_3d_style(btn, Color("#58cc02"))

		for c in btn.pressed.get_connections():
			btn.pressed.disconnect(c["callable"])
		btn.pressed.connect(func(): _move_word_back(btn, w_text))

func _move_word_back(btn: Button, w_text: String) -> void:
	if btn.get_parent() == target_zone:
		target_zone.remove_child(btn)
		word_bank.add_child(btn)
		# Restore bank style
		apply_3d_style(btn, Color(0.42, 0.39, 1.0, 1))

		for c in btn.pressed.get_connections():
			btn.pressed.disconnect(c["callable"])
		btn.pressed.connect(func(): _move_word_to_target(btn, w_text))

func _on_submit_pressed() -> void:
	var user_sentence = ""
	for i in range(target_zone.get_child_count()):
		var node = target_zone.get_child(i)
		if node is Button:
			user_sentence += node.text + (" " if i < target_zone.get_child_count() - 1 else "")

	var correct_sentence = str(question_data.get("answer", question_data.get("Answer", ""))).strip_edges()
	var is_correct = (user_sentence.to_lower() == correct_sentence.to_lower())

	submit_btn.disabled = true
	for child in target_zone.get_children():
		if child is Button: child.disabled = true
	for child in word_bank.get_children():
		if child is Button: child.disabled = true

	if is_correct:
		target_zone.modulate = Color(0.5, 1.0, 0.5)
	else:
		target_zone.modulate = Color(1.0, 0.5, 0.5)
		var lbl = Label.new()
		lbl.text = "Dap an: " + correct_sentence
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		add_child(lbl)

	submit(is_correct, user_sentence)
