extends Node
## VNEG_Godot/scripts/autoloads/AuthManager.gd
##
## Quản lý thông tin đăng nhập và Token người dùng.
## Lưu trữ token cục bộ thông qua ConfigFile (hoạt động giống localStorage).

const SAVE_PATH = "user://vneg_auth.cfg"

var current_user: Dictionary = {}
var session_token: String = ""

# Được gọi tự động khi Autoload khởi chạy
func _ready():
	load_session()

# ==========================================================
# PUBLIC METHODS
# ==========================================================

func get_token() -> String:
	return session_token

func is_logged_in() -> bool:
	return session_token != "" and current_user.has("id")

func get_user_id() -> int:
	if current_user.has("id"):
		return int(current_user["id"])
	return 0

func get_user_role() -> String:
	if current_user.has("role"):
		return current_user["role"]
	return "user"

func save_session(token: String, user_data: Dictionary) -> void:
	session_token = token
	current_user = user_data
	
	# Lưu vào file cục bộ
	var config = ConfigFile.new()
	config.set_value("Auth", "Token", token)
	config.set_value("Auth", "User", current_user)
	config.save(SAVE_PATH)

func clear_session() -> void:
	session_token = ""
	current_user = {}
	
	var dir = DirAccess.open("user://")
	if dir and dir.file_exists("vneg_auth.cfg"):
		dir.remove("vneg_auth.cfg")

func load_session() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		session_token = config.get_value("Auth", "Token", "")
		current_user = config.get_value("Auth", "User", {})
