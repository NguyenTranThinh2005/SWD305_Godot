extends QuestionBase
## QuestionPictureGuess.gd — Nhin tranh doan tu

var image_rect: TextureRect
var input_field: LineEdit
var image_loader: HTTPRequest

func _do_setup() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 12)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Parse question text from data
	var raw_data = question_data.get("data", question_data.get("Data", ""))
	var data_dict = null
	if typeof(raw_data) == TYPE_DICTIONARY:
		data_dict = raw_data
	elif typeof(raw_data) == TYPE_STRING and raw_data != "":
		var json = JSON.new()
		if json.parse(raw_data) == OK and typeof(json.data) == TYPE_DICTIONARY:
			data_dict = json.data
	
	var q_text = ""
	if data_dict != null:
		q_text = str(data_dict.get("question", data_dict.get("Question", "")))
	
	if q_text == "" and typeof(raw_data) == TYPE_STRING and not raw_data.begins_with("{"):
		q_text = raw_data

	if q_text == "":
		q_text = "Doán từ từ bức tranh"

	# Question text
	if q_text != "" and q_text != raw_data:
		var q_lbl = Label.new()
		q_lbl.text = q_text
		q_lbl.add_theme_font_size_override("font_size", 20)
		q_lbl.add_theme_color_override("font_color", Color("#4b4b4b"))
		q_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		q_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		add_child(q_lbl)

	# Input
	input_field = LineEdit.new()
	input_field.placeholder_text = "Nhap cau tra loi..."
	input_field.add_theme_font_size_override("font_size", 20)
	input_field.add_theme_color_override("font_color", Color.WHITE)
	input_field.custom_minimum_size = Vector2(0, 45)
	input_field.alignment = HORIZONTAL_ALIGNMENT_CENTER
	input_field.caret_blink = true

	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(0.1, 0.1, 0.15, 1)
	input_style.border_width_bottom = 3
	input_style.border_color = Color(0.42, 0.39, 1.0, 1)
	input_style.corner_radius_top_left = 6
	input_style.corner_radius_top_right = 6
	input_style.content_margin_left = 12
	input_style.content_margin_right = 12
	input_style.content_margin_top = 8
	input_style.content_margin_bottom = 8
	input_field.add_theme_stylebox_override("normal", input_style)
	add_child(input_field)

	var submit_btn = Button.new()
	submit_btn.text = "Xac nhan"
	submit_btn.custom_minimum_size = Vector2(200, 45)
	apply_3d_style(submit_btn, Color("#1cb0f6"))
	add_child(submit_btn)

	submit_btn.pressed.connect(_on_submit_pressed)
	input_field.text_submitted.connect(func(_text): _on_submit_pressed())

	# Load Image using base helper
	var img_url = str(question_data.get("imageUrl", question_data.get("image_url", question_data.get("ImageUrl", ""))))
	_add_image_display(img_url)

	input_field.call_deferred("grab_focus")

func _on_submit_pressed() -> void:
	var user_ans = input_field.text.strip_edges()
	if user_ans.is_empty():
		return

	input_field.editable = false
	for child in get_children():
		if child is Button:
			child.disabled = true

	var correct_ans_str = str(question_data.get("answer", question_data.get("Answer", ""))).strip_edges()
	var is_correct = (user_ans.to_lower() == correct_ans_str.to_lower())

	var result_style = StyleBoxFlat.new()
	result_style.content_margin_left = 12
	result_style.content_margin_right = 12
	result_style.content_margin_top = 8
	result_style.content_margin_bottom = 8
	result_style.corner_radius_top_left = 6
	result_style.corner_radius_top_right = 6

	if is_correct:
		result_style.bg_color = Color(0.1, 0.3, 0.15, 1)
		result_style.border_width_bottom = 3
		result_style.border_color = Color(0.3, 1.0, 0.4, 1)
		input_field.add_theme_stylebox_override("read_only", result_style)
		input_field.add_theme_color_override("font_uneditable_color", Color(0.3, 1.0, 0.5))
	else:
		result_style.bg_color = Color(0.3, 0.1, 0.1, 1)
		result_style.border_width_bottom = 3
		result_style.border_color = Color(1.0, 0.3, 0.3, 1)
		input_field.add_theme_stylebox_override("read_only", result_style)
		input_field.add_theme_color_override("font_uneditable_color", Color(1.0, 0.4, 0.4))

		var lbl = Label.new()
		lbl.text = "Dap an dung: " + correct_ans_str
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		add_child(lbl)

	submit(is_correct, user_ans)
