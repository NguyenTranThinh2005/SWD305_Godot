extends QuestionBase
## QuestionMultipleChoice.gd — Chọn 1 đáp án đúng

func _do_setup() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 10)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Support image for Multiple Choice
	var img_url = str(question_data.get("imageUrl", question_data.get("image_url", question_data.get("ImageUrl", ""))))
	_add_image_display(img_url)

	var raw_data = question_data.get("data", question_data.get("Data", ""))
	var options = []
	var correct_ans = str(question_data.get("answer", question_data.get("Answer", "")))

	var data_dict = null
	if typeof(raw_data) == TYPE_DICTIONARY:
		data_dict = raw_data
	elif typeof(raw_data) == TYPE_STRING and raw_data != "":
		var json = JSON.new()
		if json.parse(raw_data) == OK:
			data_dict = json.data
	
	if data_dict != null:
		if typeof(data_dict) == TYPE_ARRAY:
			options = data_dict
		elif typeof(data_dict) == TYPE_DICTIONARY:
			options = data_dict.get("options", data_dict.get("Options", data_dict.get("choices", [])))
	
	# Fallback: if options is STILL empty, try parsing the whole raw_data if it's an array string
	if options.size() == 0:
		if typeof(raw_data) == TYPE_STRING:
			if raw_data.begins_with("["):
				var json_fallback = JSON.new()
				if json_fallback.parse(raw_data) == OK:
					options = json_fallback.data
			else:
				options = raw_data.split(",")
		elif typeof(raw_data) == TYPE_ARRAY:
			options = raw_data

	# Final fallback to ensure SOMETHING is clickable
	if options.size() == 0 and correct_ans != "":
		options = [correct_ans]

	if options.size() == 0:
		options = [correct_ans]

	var labels = ["A", "B", "C", "D", "E", "F"]

	for i in range(options.size()):
		var btn = Button.new()
		var opt_text = str(options[i]).strip_edges().replace("\"", "")
		var prefix = labels[i] if i < labels.size() else str(i + 1)
		btn.text = prefix + ".  " + opt_text
		btn.custom_minimum_size = Vector2(0, 55)
		btn.add_theme_font_size_override("font_size", 20)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		apply_3d_style(btn)

		add_child(btn)

		btn.pressed.connect(func():
			_on_option_selected(btn, opt_text, correct_ans)
		)

func _on_option_selected(btn: Button, selected: String, correct: String) -> void:
	for child in get_children():
		if child is Button:
			child.disabled = true

	var is_correct = (selected.to_lower() == correct.to_lower())

	if is_correct:
		_style_correct(btn)
	else:
		_style_wrong(btn)
		# Highlight the correct answer
		for child in get_children():
			if child is Button and child.text.substr(4).to_lower() == correct.to_lower():
				_style_correct(child)
			elif child is Button:
				var btn_text = child.text
				var dot_pos = btn_text.find(".")
				if dot_pos > 0:
					var content = btn_text.substr(dot_pos + 1).strip_edges()
					if content.to_lower() == correct.to_lower():
						_style_correct(child)

	submit(is_correct, selected)

func _style_correct(btn: Button) -> void:
	apply_3d_correct(btn)

func _style_wrong(btn: Button) -> void:
	apply_3d_wrong(btn)
