extends VBoxContainer
class_name QuestionBase

signal answer_submitted(is_correct: bool, selected_answer_raw: Variant)

var question_data: Dictionary = {}

func setup(data: Dictionary) -> void:
	question_data = data
	_do_setup()

# Virtual function to be overridden by child classes
func _do_setup() -> void:
	pass

# Helper to emit the answer signal
func submit(is_correct: bool, raw_answer: Variant) -> void:
	answer_submitted.emit(is_correct, raw_answer)

func _add_image_display_by_data(data: Dictionary) -> TextureRect:
	var url = str(data.get("imageUrl", data.get("image_url", data.get("ImageUrl", ""))))
	return _add_image_display(url)

func _add_image_display(url: String) -> TextureRect:
	if url == "" or not url.begins_with("http"):
		return null
		
	var img_panel = PanelContainer.new()
	img_panel.custom_minimum_size = Vector2(0, 150)
	img_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.5)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	img_panel.add_theme_stylebox_override("panel", style)
	
	var rect = TextureRect.new()
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	img_panel.add_child(rect)
	
	# Add to top of VBox (usually before question text or options)
	add_child(img_panel)
	move_child(img_panel, 0) 
	
	# Async Load
	var loader = HTTPRequest.new()
	add_child(loader)
	loader.request_completed.connect(func(_result, response_code, _headers, body):
		if response_code == 200:
			var image = Image.new()
			var err = image.load_jpg_from_buffer(body)
			if err != OK: err = image.load_png_from_buffer(body)
			if err != OK: err = image.load_webp_from_buffer(body)
			if err == OK:
				rect.texture = ImageTexture.create_from_image(image)
		loader.queue_free()
	)
	loader.request(url)
	return rect
