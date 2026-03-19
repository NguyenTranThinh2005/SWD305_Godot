extends QuestionBase
## QuestionListenCatch.gd — Chữa nói ngọng (L/N, TR/CH)
## Biến thể của QuestionListenChoose nhưng nút bấm to hơn, rõ ràng hơn để người chơi phân biệt cặp từ.

var audio_player: AudioStreamPlayer
var play_btn: Button
var is_audio_ready: bool = false

func _do_setup() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 24)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var title = Label.new()
	title.text = "Lắng nghe và chọn âm đúng để không bị ngọng nhé!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	add_child(title)

	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

	play_btn = Button.new()
	play_btn.text = "Đang tải âm thanh bài tập..."
	play_btn.add_theme_font_size_override("font_size", 28)
	play_btn.custom_minimum_size = Vector2(0, 80)
	
	apply_3d_style(play_btn, Color("#ff9600"))
	
	add_child(play_btn)

	play_btn.pressed.connect(func():
		if is_audio_ready and audio_player.stream != null:
			audio_player.play()
	)

	var audio_url = str(question_data.get("audioUrl", question_data.get("audio_url", question_data.get("AudioUrl", ""))))
	if audio_url != "" and audio_url.begins_with("http"):
		_load_audio_from_url(audio_url)
	elif audio_url != "" and audio_url.begins_with("res://"):
		var stream = load(audio_url)
		if stream is AudioStream:
			audio_player.stream = stream
			is_audio_ready = true
			play_btn.text = "▶ NGHE ÂM THANH"
			play_btn.disabled = false
		else:
			play_btn.text = "Lỗi âm thanh gốc (res://)"
			play_btn.disabled = true
	else:
		play_btn.text = "Không có âm thanh (chọn đáp án)"
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

	var correct_ans = str(question_data.get("answer", question_data.get("Answer", "")))

	var options_box = HBoxContainer.new()
	options_box.alignment = BoxContainer.ALIGNMENT_CENTER
	options_box.add_theme_constant_override("separation", 40)
	options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(options_box)

	# Shuffle options to avoid pattern guessing
	options.shuffle()

	for i in range(options.size()):
		var btn = Button.new()
		var opt_text = str(options[i]).strip_edges()
		btn.text = opt_text
		btn.add_theme_font_size_override("font_size", 32)
		btn.custom_minimum_size = Vector2(250, 100)
		
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
			play_btn.text = "▶ NGHE ÂM THANH"
			play_btn.disabled = false
		else:
			play_btn.text = "⚠️ Định dạng lỗi (Giả lập Nghe)"
			play_btn.disabled = false
	else:
		play_btn.text = "🔊 Audio Mẫu (Link giả định)"
		play_btn.disabled = false

func _on_option_selected(btn: Button, selected: String, correct: String, options_box: HBoxContainer) -> void:
	for child in options_box.get_children():
		child.disabled = true

	var is_correct = (selected.to_lower() == correct.to_lower())

	if is_correct:
		_style_correct(btn)
	else:
		_style_wrong(btn)
		for child in options_box.get_children():
			if child.text.to_lower() == correct.to_lower():
				_style_correct(child)

	submit(is_correct, selected)

func _style_correct(btn: Button) -> void:
	apply_3d_correct(btn)

func _style_wrong(btn: Button) -> void:
	apply_3d_wrong(btn)
