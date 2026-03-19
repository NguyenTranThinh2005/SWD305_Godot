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
	if url == "":
		return null
	if not url.begins_with("http") and not url.begins_with("res://"):
		return null
		
	var img_panel = PanelContainer.new()
	img_panel.custom_minimum_size = Vector2(0, 150)
	img_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.95, 0.95, 1.0)
	style.border_width_bottom = 4
	style.border_color = Color(0.85, 0.85, 0.85, 1.0)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_right = 16
	style.corner_radius_bottom_left = 16
	img_panel.add_theme_stylebox_override("panel", style)
	
	var rect = TextureRect.new()
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	img_panel.add_child(rect)
	
	# Add to top of VBox (usually before question text or options)
	add_child(img_panel)
	move_child(img_panel, 0) 
	
	if url.begins_with("res://"):
		var bytes = FileAccess.get_file_as_bytes(url)
		var raw_img = Image.new()
		var err = raw_img.load_webp_from_buffer(bytes)
		if err != OK:
			err = raw_img.load_png_from_buffer(bytes)
		if err != OK:
			err = raw_img.load_jpg_from_buffer(bytes)
			
		if err == OK:
			rect.texture = ImageTexture.create_from_image(raw_img)
		else:
			var res = load(url)
			if res is Texture2D: rect.texture = res
		return rect
		
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
	loader.request(url, ["User-Agent: Mozilla/5.0"])
	return rect

func apply_3d_style(btn: Button, base_color: Color = Color("#1cb0f6")) -> void:
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	btn.add_theme_color_override("font_disabled_color", Color.WHITE)
	
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
	
	var disabled_style = style.duplicate()
	disabled_style.bg_color = base_color.lightened(0.2)
	disabled_style.border_width_bottom = 4
	btn.add_theme_stylebox_override("disabled", disabled_style)

func apply_3d_correct(btn: Button) -> void:
	apply_3d_style(btn, Color("#58cc02")) # Green
	
func apply_3d_wrong(btn: Button) -> void:
	apply_3d_style(btn, Color("#ff4b4b")) # Red
