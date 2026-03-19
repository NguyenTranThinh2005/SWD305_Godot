extends QuestionBase
## QuestionFindError.gd — Tim tu viet sai

var flow_container: HFlowContainer

func _do_setup() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 15)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var instr_lbl = Label.new()
	instr_lbl.text = "Bam vao tu ban nghi la SAI chinh ta:"
	instr_lbl.add_theme_font_size_override("font_size", 18)
	instr_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instr_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	add_child(instr_lbl)

	flow_container = HFlowContainer.new()
	flow_container.custom_minimum_size = Vector2(0, 80)
	flow_container.alignment = FlowContainer.ALIGNMENT_CENTER
	flow_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow_container.add_theme_constant_override("h_separation", 8)
	flow_container.add_theme_constant_override("v_separation", 8)
	add_child(flow_container)

	# Parse data
	var raw_data = question_data.get("data", question_data.get("Data", ""))
	var words = []
	var data_dict = null
	
	if typeof(raw_data) == TYPE_ARRAY:
		words = raw_data
	elif typeof(raw_data) == TYPE_DICTIONARY:
		data_dict = raw_data
	elif typeof(raw_data) == TYPE_STRING and raw_data != "":
		var json = JSON.new()
		if json.parse(raw_data) == OK:
			if typeof(json.data) == TYPE_ARRAY:
				words = json.data
			elif typeof(json.data) == TYPE_DICTIONARY:
				data_dict = json.data
	
	if data_dict != null:
		var w = data_dict.get("words", data_dict.get("Words", data_dict.get("options", [])))
		if typeof(w) == TYPE_ARRAY:
			words = w
			
	if words.size() == 0 and typeof(raw_data) == TYPE_STRING:
		words = raw_data.replace("[", "").replace("]", "").replace("\"", "").split(",")

	var correct_ans = str(question_data.get("answer", question_data.get("Answer", ""))).strip_edges()

	for i in range(words.size()):
		var w = str(words[i]).strip_edges()
		if w == "": continue
		var btn = Button.new()
		btn.text = w
		btn.add_theme_font_size_override("font_size", 24)
		btn.custom_minimum_size = Vector2(0, 48)

		apply_3d_style(btn)

		flow_container.add_child(btn)
		btn.pressed.connect(func():
			_on_word_selected(btn, w, correct_ans, i)
		)

func _on_word_selected(btn: Button, selected_word: String, correct_word: String, index: int) -> void:
	for child in flow_container.get_children():
		child.disabled = true

	var is_correct = false
	if correct_word.is_valid_int() and int(correct_word) == index:
		is_correct = true
	elif selected_word.to_lower() == correct_word.to_lower():
		is_correct = true

	if is_correct:
		_style_word_correct(btn)
	else:
		_style_word_wrong(btn)
		for i in range(flow_container.get_child_count()):
			var child = flow_container.get_child(i)
			if (correct_word.is_valid_int() and i == int(correct_word)) or child.text.to_lower() == correct_word.to_lower():
				_style_word_correct(child)

	submit(is_correct, selected_word)

func _style_word_correct(btn: Button) -> void:
	apply_3d_correct(btn)

func _style_word_wrong(btn: Button) -> void:
	apply_3d_wrong(btn)
