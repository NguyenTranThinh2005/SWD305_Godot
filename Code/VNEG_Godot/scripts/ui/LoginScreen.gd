extends Control
## VNEG_Godot/scripts/ui/LoginScreen.gd
##
## Xử lý giao diện Đăng nhập và Đăng ký.
## Gắn script này vào Node Root của màn hình Login.

# Tham chiếu tới các Node giao diện (Cần đặt đúng tên trong Godot Editor)
@onready var email_input: LineEdit = $VBoxContainer/EmailInput
@onready var password_input: LineEdit = $VBoxContainer/PasswordInput
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var login_button: Button = $VBoxContainer/LoginButton
@onready var register_button: Button = $VBoxContainer/RegisterButton

func _ready():
	# Gọi kết nối tín hiệu (bạn cũng có thể kết nối trong thẻ Node của Godot)
	login_button.pressed.connect(_on_login_pressed)
	register_button.pressed.connect(_on_register_pressed)
	
	# Nếu đã lưu token từ trước thì tự động login
	if AuthManager.is_logged_in():
		_go_to_main_menu()

func _on_login_pressed() -> void:
	var email = email_input.text.strip_edges()
	var password = password_input.text
	
	if email == "" or password == "":
		show_status("Vui lòng nhập Email và Mật khẩu!", Color.RED)
		return
		
	set_loading(true)
	show_status("Đang đăng nhập...", Color.WHITE)
	
	# Gọi API Autoload
	var response = await API.login(email, password)
	print(response)
	set_loading(false)
	
	if response["ok"] and response["data"]:
		show_status("Đăng nhập thành công!", Color.GREEN)
		
		# Trích xuất Token và Dữ liệu user
		var token = response["data"]["token"]
		var user_info = response["data"]["user"]
		
		# Lưu vào Autoload
		AuthManager.save_session(token, user_info)
		
		_go_to_main_menu()
	else:
		show_status(str(response["data"]), Color.RED)

func _on_register_pressed() -> void:
	var email = email_input.text.strip_edges()
	var password = password_input.text
	
	if email == "" or password == "":
		show_status("Cần nhập Email và Text để Đăng ký", Color.RED)
		return
		
	set_loading(true)
	show_status("Đang tạo tài khoản...", Color.WHITE)
	
	# Ví dụ đăng ký: grade mặc định là 1, region mặc định, avatar mặc định
	var response = await API.register(email, password, 1, "Miền Bắc", "🐉")
	
	set_loading(false)
	
	if response["ok"]:
		show_status("Tạo tài khoản thành công! Tự động đăng nhập...", Color.GREEN)
		# Đăng ký thành công thì gọi tiếp API login
		_on_login_pressed()
	else:
		show_status("Lỗi đăng ký: " + str(response["data"]), Color.RED)

func show_status(msg: String, color: Color) -> void:
	if status_label:
		status_label.text = msg
		status_label.add_theme_color_override("font_color", color)

func set_loading(is_loading: bool) -> void:
	login_button.disabled = is_loading
	register_button.disabled = is_loading
	email_input.editable = !is_loading
	password_input.editable = !is_loading

func _go_to_main_menu() -> void:
	# Chuyển cảnh sang màn hình MainMenu
	# Yêu cầu bạn phải tạo scene res://scenes/MainMenu.tscn trước đó
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
