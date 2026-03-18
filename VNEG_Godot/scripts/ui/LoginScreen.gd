extends Control
## VNEG_Godot/scripts/ui/LoginScreen.gd
##
## Xử lý giao diện Đăng nhập và Đăng ký mở rộng.

# Containers
@onready var login_box: VBoxContainer = %LoginBox
@onready var register_box: VBoxContainer = %RegisterBox

# Login Fields
@onready var email_input: LineEdit = %LoginBox/EmailInput
@onready var password_input: LineEdit = %LoginBox/PasswordInput
@onready var login_button: Button = %LoginBox/LoginButton
@onready var to_register_button: LinkButton = %LoginBox/ToRegisterButton
@onready var to_guest_button: LinkButton = %LoginBox/ToGuestButton

# Register Fields
@onready var reg_email_input: LineEdit = %RegisterBox/RegEmailInput
@onready var reg_password_input: LineEdit = %RegisterBox/RegPasswordInput
@onready var phone_input: LineEdit = %RegisterBox/PhoneInput
@onready var grade_input: OptionButton = %RegisterBox/HBoxGrade/GradeInput
@onready var region_input: OptionButton = %RegisterBox/HBoxRegion/RegionInput
@onready var submit_register_button: Button = %RegisterBox/SubmitRegisterButton
@onready var to_login_button: LinkButton = %RegisterBox/ToLoginButton

# Guest Fields
@onready var guest_box: VBoxContainer = %GuestBox
@onready var guest_name_input: LineEdit = %GuestBox/GuestNameInput
@onready var submit_guest_button: Button = %GuestBox/SubmitGuestButton
@onready var to_login_button_guest: LinkButton = %GuestBox/ToLoginButtonGuest

# Shared
@onready var status_label: Label = $CenterContainer/PanelContainer/VBoxContainer/StatusLabel

func _ready():
	# Kết nối tín hiệu
	login_button.pressed.connect(_on_login_pressed)
	to_register_button.pressed.connect(_show_register)
	to_guest_button.pressed.connect(_show_guest)
	
	submit_register_button.pressed.connect(_on_register_pressed)
	to_login_button.pressed.connect(_show_login)
	
	submit_guest_button.pressed.connect(_on_guest_pressed)
	to_login_button_guest.pressed.connect(_show_login)
	
	# Khởi tạo mặc định
	_show_login()
	
	# Nếu đã lưu token từ trước thì tự động login
	if AuthManager.is_logged_in():
		_go_to_main_menu()

func _show_login():
	login_box.show()
	register_box.hide()
	guest_box.hide()
	show_status("", Color.WHITE)

func _show_register():
	login_box.hide()
	register_box.show()
	guest_box.hide()
	show_status("", Color.WHITE)

func _show_guest():
	login_box.hide()
	register_box.hide()
	guest_box.show()
	show_status("", Color.WHITE)

func _on_login_pressed() -> void:
	var email = email_input.text.strip_edges()
	var password = password_input.text
	
	if email == "" or password == "":
		show_status("Vui lòng nhập Email và Mật khẩu!", Color.RED)
		return
		
	set_loading(true)
	show_status("Đang đăng nhập...", Color.WHITE)
	
	var response = await API.login(email, password)
	set_loading(false)
	
	if response["ok"] and response["data"]:
		show_status("Đăng nhập thành công!", Color.GREEN)
		
		var data = response["data"]
		var token = data.get("token", "")
		var user_info = data.get("user", {})
		
		if token == "":
			show_status("Lỗi: Không nhận được Token từ máy chủ.", Color.RED)
			return

		AuthManager.save_session(token, user_info)
		_go_to_main_menu()
	else:
		var err_msg = "Lỗi đăng nhập: "
		
		if typeof(response["data"]) == TYPE_STRING:
			err_msg += response["data"]
		elif typeof(response["data"]) == TYPE_DICTIONARY:
			if response["data"].has("message"):
				err_msg += str(response["data"]["message"])
			else:
				err_msg += JSON.stringify(response["data"])
		else:
			err_msg += "Mã lỗi HTTP " + str(response["status"])
		
		show_status(err_msg, Color.RED)

func _on_register_pressed() -> void:
	var email = reg_email_input.text.strip_edges()
	var password = reg_password_input.text
	var phone = phone_input.text.strip_edges()
	var grade = grade_input.get_selected_id() + 1 # ID 0 -> Grade 1
	
	# Map Region (OptionButton index) -> API friendly string
	var region_idx = region_input.selected
	var region_val = "Bac"
	match region_idx:
		0: region_val = "Bac"
		1: region_val = "Trung"
		2: region_val = "Nam"
	
	if email == "" or password == "":
		show_status("Email và Mật khẩu là bắt buộc!", Color.RED)
		return
		
	set_loading(true)
	show_status("Đang tạo tài khoản...", Color.WHITE)
	
	
	# Gọi API Register với tất cả các trường
	var response = await API.register(
		email,
		password,
		phone,
		grade,
		region_val,
		"🐉"
	)
	print("STATUS:", response.status)
	print("DATA:", response.data)
	
	set_loading(false)
	
	if response["ok"]:
		show_status("Tạo tài khoản thành công! Quay lại đăng nhập...", Color.GREEN)
		# Tự động điền email vào form login và chuyển view
		email_input.text = email
		_show_login()
	else:
		var err_res = response["data"]
		var err_msg = "Lỗi đăng ký: "
		
		if typeof(err_res) == TYPE_STRING:
			err_msg += err_res
		elif typeof(err_res) == TYPE_DICTIONARY:
			if err_res.has("message"):
				err_msg += str(err_res["message"]) + " "
			if err_res.has("detail"):
				err_msg += str(err_res["detail"])
			if not err_res.has("message") and not err_res.has("detail"):
				err_msg += JSON.stringify(err_res)
		else:
			err_msg += "HTTP " + str(response["status"])
			
		show_status(err_msg, Color.RED)

func _on_guest_pressed() -> void:
	var guest_name = guest_name_input.text.strip_edges()
	if guest_name == "":
		show_status("Vui lòng nhập Tên Khách!", Color.RED)
		return
		
	var mock_user = {
		"id": 0,
		"email": "guest@vneg.local",
		"username": guest_name,
		"role": "user",
		"avatarUrl": "🐉"
	}
	
	AuthManager.save_session("GUEST_TOKEN", mock_user)
	show_status("Đang vào game...", Color.GREEN)
	_go_to_main_menu()

func show_status(msg: String, color: Color) -> void:
	if status_label:
		status_label.text = msg
		status_label.add_theme_color_override("font_color", color)

func set_loading(is_loading: bool) -> void:
	login_button.disabled = is_loading
	submit_register_button.disabled = is_loading
	submit_guest_button.disabled = is_loading
	to_guest_button.disabled = is_loading
	email_input.editable = !is_loading
	reg_email_input.editable = !is_loading
	guest_name_input.editable = !is_loading

func _go_to_main_menu() -> void:
	var scene_path = "res://scenes/MainMenu.tscn"
	if FileAccess.file_exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		show_status("Lỗi: Không tìm thấy scene MainMenu.tscn", Color.YELLOW)
