extends QuestionBase
## QuestionListenChoose.gd — Nghe va chon dap an

var audio_player: AudioStreamPlayer
var play_btn: Button
var is_audio_ready: bool = false

func _do_setup() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 12)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

	# Support image for Listening questions
	_add_image_display_by_data(question_data)

	play_btn = Button.new()
	play_btn.add_theme_font_size_override("font_size", 20)
	play_btn.custom_minimum_size = Vector2(0, 55)
	add_child(play_btn)

	play_btn.pressed.connect(func():
		if is_audio_ready and audio_player.stream != null:
			audio_player.play()
	)

	# Load Audio from URL
	var audio_url = str(question_data.get("audioUrl", question_data.get("audio_url", question_data.get("AudioUrl", ""))))

	if audio_url != "" and audio_url.begins_with("http"):
		_load_audio_from_url(audio_url)
		play_btn.text = "Dang tai am thanh..."
		play_btn.disabled = true
	elif audio_url != "" and audio_url.begins_with("res://"):
		var stream = load(audio_url)
		if stream is AudioStream:
			audio_player.stream = stream
			is_audio_ready = true
			play_btn.text = "Nghe lai"
			play_btn.disabled = false
		else:
			play_btn.text = "Loi file am thanh goc (res://)"
			play_btn.disabled = true
	else:
		play_btn.text = "Khong co am thanh (chon dap an)"
		play_btn.disabled = true

	# Parse options from data
	var raw_data = question_data.get("data", question_data.get("Data", ""))
	var options = []
	var data_dict = null
	
	if typeof(raw_data) == TYPE_ARRAY:
		options = raw_data
	elif typeof(raw_data) == TYPE_DICTIONARY:
		data_dict = raw_data
	elif typeof(raw_data) == TYPE_STRING and raw_data != "":
		var json = JSON.new()
		if json.parse(raw_data) == OK:
			if typeof(json.data) == TYPE_ARRAY:
				options = json.data
			elif typeof(json.data) == TYPE_DICTIONARY:
				data_dict = json.data
	
	if data_dict != null:
		var opts = data_dict.get("options", data_dict.get("Options", data_dict.get("choices", [])))
		if typeof(opts) == TYPE_ARRAY:
			options = opts

	if options.size() == 0 and typeof(raw_data) == TYPE_STRING:
		options = raw_data.split(",")

	var correct_ans = str(question_data.get("answer", question_data.get("Answer", "")))

	var options_box = VBoxContainer.new()
	options_box.add_theme_constant_override("separation", 8)
	options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(options_box)

	var labels = ["A", "B", "C", "D", "E"]
	for i in range(options.size()):
		var btn = Button.new()
		var opt_text = str(options[i]).strip_edges()
		var prefix = labels[i] if i < labels.size() else str(i + 1)
		btn.text = prefix + ".  " + opt_text
		btn.add_theme_font_size_override("font_size", 20)
		btn.custom_minimum_size = Vector2(0, 50)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		apply_3d_style(btn)

		options_box.add_child(btn)
		btn.pressed.connect(func():
			_on_option_selected(btn, opt_text, correct_ans, options_box)
		)

func _load_audio_from_url(url: String) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_audio_downloaded)
	http.request(url, ["User-Agent: Mozilla/5.0"])
	play_btn.text = "Dang tai..."

func _on_audio_downloaded(_result, response_code, headers, body) -> void:
	if response_code == 200 and body.size() > 0:
		var stream = null
		var is_ogg = false
		for h in headers:
			if "audio/ogg" in h.to_lower():
				is_ogg = true
				break
		if not is_ogg and body.size() > 4:
			if body[0] == 0x4f and body[1] == 0x67:
				is_ogg = true

		if is_ogg:
			stream = AudioStreamOggVorbis.load_from_buffer(body)
		else:
			stream = AudioStreamMP3.new()
			stream.data = body

		if stream:
			audio_player.stream = stream
			is_audio_ready = true
			play_btn.text = "Nghe lai"
			play_btn.disabled = false
		else:
			play_btn.text = "⚠️ Định dạng lỗi (Giả lập Nghe)"
			play_btn.disabled = false
	else:
		play_btn.text = "🔊 Audio Mẫu (Link giả định)"
		play_btn.disabled = false

func _on_option_selected(btn: Button, selected: String, correct: String, options_box: VBoxContainer) -> void:
	for child in options_box.get_children():
		child.disabled = true

	var is_correct = (selected.to_lower() == correct.to_lower())

	if is_correct:
		_style_correct(btn)
	else:
		_style_wrong(btn)
		for child in options_box.get_children():
			var t = child.text
			var dot_pos = t.find(".")
			if dot_pos > 0:
				var content = t.substr(dot_pos + 1).strip_edges()
				if content.to_lower() == correct.to_lower():
					_style_correct(child)

	submit(is_correct, selected)

func _style_correct(btn: Button) -> void:
	apply_3d_correct(btn)

func _style_wrong(btn: Button) -> void:
	apply_3d_wrong(btn)
