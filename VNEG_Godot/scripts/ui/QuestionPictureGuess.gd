extends QuestionBase

var image_rect: TextureRect
var input_field: LineEdit
var image_loader: HTTPRequest

func _do_setup() -> void:
	# Inherits from QuestionBase (VBoxContainer)
	# Set some spacing/alignment
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 20)
	
	image_rect = TextureRect.new()
	image_rect.custom_minimum_size = Vector2(320, 240)
	image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(image_rect)
	
	# Hint / Description - Check multiple common keys used in different versions
	var hint_text = ""
	var keys_to_check = ["explanation", "Explanation", "description", "hint"]
	for k in keys_to_check:
		if question_data.has(k) and str(question_data[k]) != "" and str(question_data[k]) != "null":
			hint_text = str(question_data[k])
			break
	
	print("[PictureGuess DEBUG] Data keys: ", question_data.keys())
	print("[PictureGuess DEBUG] Found Hint: ", hint_text)
	
	if hint_text != "":
		var hint_lbl = Label.new()
		hint_lbl.text = "Gợi ý: " + hint_text
		hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint_lbl.add_theme_color_override("font_color", Color.YELLOW)
		add_child(hint_lbl)
	
	input_field = LineEdit.new()
	input_field.placeholder_text = "Nhập câu trả lời..."
	input_field.custom_minimum_size = Vector2(0, 50)
	input_field.alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(input_field)
	
	var submit_btn = Button.new()
	submit_btn.text = "Kiểm tra"
	submit_btn.custom_minimum_size = Vector2(0, 50)
	add_child(submit_btn)
	
	submit_btn.pressed.connect(_on_submit_pressed)
	input_field.text_submitted.connect(func(_text): _on_submit_pressed())
	
	# Load Images - Support multiple URLs separated by '|'
	var img_raw = str(question_data.get("imageUrl", ""))
	if img_raw == "":
		img_raw = str(question_data.get("image_url", ""))
		
	if img_raw != "":
		var urls = img_raw.split("|")
		if urls.size() > 1:
			# Multi-image mode (Pictogram)
			image_rect.queue_free() # Remove the single placeholder
			var container = HBoxContainer.new()
			container.alignment = BoxContainer.ALIGNMENT_CENTER
			container.add_theme_constant_override("separation", 10)
			add_child(container)
			move_child(container, 0) # Keep it at the top or after hint
			
			for url in urls:
				var rect = TextureRect.new()
				rect.custom_minimum_size = Vector2(240, 180) # Smaller for side-by-side
				rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				container.add_child(rect)
				_load_image_to_rect(url.strip_edges(), rect)
		else:
			# Single image mode
			_load_image_to_rect(urls[0].strip_edges(), image_rect)
	else:
		push_warning("PictureGuess: imageUrl is missing in q_data")

var _image_retries: Dictionary = {}
const MAX_IMG_RETRIES = 3

func _load_image_to_rect(url: String, target_rect: TextureRect) -> void:
	if not url.begins_with("http"): 
		push_error("PictureGuess: Invalid URL: " + url)
		return
	
	_image_retries[target_rect] = 0
	_do_image_request(url, target_rect)

func _do_image_request(url: String, target_rect: TextureRect) -> void:
	var loader = HTTPRequest.new()
	loader.use_threads = true # Use threads to prevent blocking
	add_child(loader)
	
	loader.request_completed.connect(func(_result, response_code, _headers, body): 
		_on_image_loaded(response_code, body, target_rect, loader, url)
	)
	
	var headers = ["User-Agent: VNEG_Godot_Game/1.5 (contact: thinhnt@fpt.edu.vn)"]
	var err = loader.request(url, headers)
	if err != OK:
		push_error("PictureGuess: HTTPRequest setup failed for " + url)

func _on_image_loaded(response_code: int, body: PackedByteArray, target_rect: TextureRect, loader: HTTPRequest, url: String) -> void:
	if response_code == 200 and body.size() > 8:
		var image = Image.new()
		var err = ERR_FILE_CORRUPT
		
		# Manual signature check for version compatibility (load_from_buffer is 4.2+)
		if body[0] == 0xFF and body[1] == 0xD8: # JPG
			err = image.load_jpg_from_buffer(body)
		elif body[0] == 0x89 and body[1] == 0x50: # PNG
			err = image.load_png_from_buffer(body)
		elif body[0] == 0x52 and body[1] == 0x49: # WEBP (RIFF)
			err = image.load_webp_from_buffer(body)
		else:
			# Fallback if no signature found
			err = image.load_png_from_buffer(body)
			if err != OK: err = image.load_jpg_from_buffer(body)
		
		if err == OK:
			# Downscale to max 512px to prevent GPU memory errors
			var MAX_SIZE = 512
			var w = image.get_width()
			var h = image.get_height()
			if w > MAX_SIZE or h > MAX_SIZE:
				var scale = float(MAX_SIZE) / float(max(w, h))
				image.resize(int(w * scale), int(h * scale), Image.INTERPOLATE_BILINEAR)
				
			var texture = ImageTexture.create_from_image(image)
			if is_instance_valid(target_rect):
				target_rect.texture = texture
				target_rect.modulate = Color.WHITE # Reset color if it was an error icon
		else:
			push_error("PictureGuess: Failed to parse image (Signatures mismatch). Size: " + str(body.size()))
			_handle_image_failure(response_code, target_rect, url)
	else:
		_handle_image_failure(response_code, target_rect, url)
	
	if is_instance_valid(loader):
		loader.queue_free()

func _handle_image_failure(response_code: int, target_rect: TextureRect, url: String) -> void:
	if is_instance_valid(target_rect) and _image_retries.has(target_rect):
		var retries = _image_retries[target_rect]
		if retries < MAX_IMG_RETRIES:
			_image_retries[target_rect] = retries + 1
			var wait_secs = pow(2.0, retries)
			print("PictureGuess: download failed (Code: ", response_code, "). Retrying in ", wait_secs, "s...")
			await get_tree().create_timer(wait_secs).timeout
			if is_instance_valid(target_rect):
				_do_image_request(url, target_rect)
		else:
			push_error("PictureGuess: download failed permanently. Code: " + str(response_code))
			if is_instance_valid(target_rect):
				target_rect.texture = load("res://assets/mario_platformer/icon.png")
				target_rect.modulate = Color(1, 0.5, 0.5) # Error color
	
func _on_submit_pressed() -> void:
	var user_ans = input_field.text.strip_edges()
	if user_ans.is_empty():
		return
		
	input_field.editable = false
	var btn = get_child(get_child_count() - 1) # last child is submit_btn
	if btn is Button:
		btn.disabled = true
	
	var correct_ans_str = str(question_data.get("answer", "")).strip_edges()
	var is_correct = (user_ans.to_lower() == correct_ans_str.to_lower())
	
	if is_correct:
		input_field.modulate = Color.GREEN
	else:
		input_field.modulate = Color.RED
		var lbl = Label.new()
		lbl.text = "Đáp án đúng: " + correct_ans_str
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.modulate = Color.GREEN
		add_child(lbl)
		
	submit(is_correct, user_ans)
