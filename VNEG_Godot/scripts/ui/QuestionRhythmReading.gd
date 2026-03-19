extends QuestionBase
## QuestionRhythmReading.gd — Chữa nói lắp bằng cách đọc chữ theo nhịp (Rhythm Reading)

var bpm: int = 60
var lyrics: Array = []
var correct_ans: String = ""

var current_lyric_index: int = -1
var rhythm_timer: Timer
var time_per_beat: float = 1.0

var word_label: Label
var status_label: Label
var beat_btn: Button
var start_btn: Button

var hits: int = 0
var missed: int = 0

var expected_hit_time: float = 0.0
var has_hit_this_beat: bool = false
var is_playing: bool = false

func _do_setup() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 16)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var raw_data = question_data.get("data", question_data.get("Data", ""))
	if typeof(raw_data) == TYPE_STRING:
		var json = JSON.new()
		if json.parse(raw_data) == OK and typeof(json.data) == TYPE_DICTIONARY:
			raw_data = json.data

	if typeof(raw_data) == TYPE_DICTIONARY:
		bpm = raw_data.get("bpm", 60)
		var l = raw_data.get("lyrics", [])
		if typeof(l) == TYPE_ARRAY:
			lyrics = l
	
	correct_ans = str(question_data.get("answer", question_data.get("Answer", "")))
	time_per_beat = 60.0 / float(max(bpm, 20))

	var info = Label.new()
	info.text = "Gõ nhịp và Đọc to từng chữ xuất hiện!\nTốc độ: " + str(bpm) + " BPM"
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 18)
	info.add_theme_color_override("font_color", Color(0.7, 0.7, 1.0))
	add_child(info)

	word_label = Label.new()
	word_label.text = "---"
	word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	word_label.add_theme_font_size_override("font_size", 48)
	word_label.add_theme_color_override("font_color", Color(1, 1, 1))
	add_child(word_label)
	
	status_label = Label.new()
	status_label.text = "Sẵn sàng"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 20)
	add_child(status_label)

	start_btn = Button.new()
	start_btn.text = "Bắt đầu đọc!"
	start_btn.add_theme_font_size_override("font_size", 24)
	start_btn.custom_minimum_size = Vector2(250, 60)
	start_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(start_btn)
	start_btn.pressed.connect(_on_start_pressed)

	beat_btn = Button.new()
	beat_btn.text = "GÕ NHỊP (SPACE)"
	beat_btn.add_theme_font_size_override("font_size", 24)
	beat_btn.custom_minimum_size = Vector2(300, 80)
	beat_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.6, 0.8, 1)
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_right = 15
	style.corner_radius_bottom_left = 15
	beat_btn.add_theme_stylebox_override("normal", style)
	
	add_child(beat_btn)
	beat_btn.pressed.connect(_on_beat_pressed)
	beat_btn.disabled = true

	rhythm_timer = Timer.new()
	rhythm_timer.wait_time = time_per_beat
	rhythm_timer.one_shot = false
	rhythm_timer.timeout.connect(_on_beat)
	add_child(rhythm_timer)

func _input(event: InputEvent) -> void:
	if is_playing and event.is_action_pressed("ui_accept"):
		_on_beat_pressed()

func _on_start_pressed() -> void:
	start_btn.disabled = true
	beat_btn.disabled = false
	is_playing = true
	hits = 0
	missed = 0
	current_lyric_index = -1
	
	# Start countdown
	word_label.text = "3"
	await get_tree().create_timer(time_per_beat).timeout
	word_label.text = "2"
	await get_tree().create_timer(time_per_beat).timeout
	word_label.text = "1"
	await get_tree().create_timer(time_per_beat).timeout
	
	_on_beat()
	rhythm_timer.start()

func _on_beat() -> void:
	if current_lyric_index >= 0 and not has_hit_this_beat:
		# Check if they missed the prev beat
		missed += 1
		_show_feedback("Trượt", Color(1, 0.3, 0.3))

	current_lyric_index += 1
	has_hit_this_beat = false
	expected_hit_time = Time.get_ticks_msec() / 1000.0

	if current_lyric_index < lyrics.size():
		word_label.text = str(lyrics[current_lyric_index])
		# Highlight effect
		word_label.modulate = Color(1.0, 1.0, 0.5)
		var tw = create_tween()
		tw.tween_property(word_label, "modulate", Color(1, 1, 1), 0.3)
	else:
		rhythm_timer.stop()
		_finish_game()

func _on_beat_pressed() -> void:
	if not is_playing or has_hit_this_beat or current_lyric_index < 0 or current_lyric_index >= lyrics.size():
		return

	var now = Time.get_ticks_msec() / 1000.0
	var diff = abs(now - expected_hit_time)
	has_hit_this_beat = true

	if diff < (time_per_beat * 0.4): # Tương đối dễ (40% window)
		hits += 1
		_show_feedback("Chuẩn!", Color(0.3, 1.0, 0.5))
		
		# Button flash
		var style = beat_btn.get_theme_stylebox("normal").duplicate()
		style.bg_color = Color(0.3, 1.0, 0.5, 1)
		beat_btn.add_theme_stylebox_override("normal", style)
		var t = create_tween()
		style.bg_color = Color(0.2, 0.6, 0.8, 1)
		t.tween_property(beat_btn, "theme_override_styles/normal", style, 0.2)
	else:
		missed += 1
		_show_feedback("Lệch nhịp!", Color(1.0, 0.6, 0.2))

func _show_feedback(txt: String, c: Color) -> void:
	status_label.text = txt
	status_label.add_theme_color_override("font_color", c)

func _finish_game() -> void:
	is_playing = false
	beat_btn.disabled = true
	var accuracy = float(hits) / float(max(1, lyrics.size()))
	var is_correct = accuracy >= 0.7 # 70% la pass

	word_label.text = "Hoàn thành!"
	status_label.text = "Đúng nhịp %.0f%% (%d/%d)" % [accuracy * 100, hits, lyrics.size()]
	
	await get_tree().create_timer(1.5).timeout
	submit(is_correct, correct_ans)
