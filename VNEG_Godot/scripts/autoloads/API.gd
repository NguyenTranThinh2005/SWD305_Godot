extends Node
## VNEG_Godot/scripts/autoloads/API.gd
##
## Quản lý HTTP Requests tới ASP.NET Backend.
## Sử dụng node HTTPRequest để gọi các RESTful APIs.

const API_BASE = "http://localhost:5290" # Thay đổi port tương ứng với file launchSettings.json

## Hàm tiện ích để thực hiện HTTP Request.
## Trả về một Dictionary có dạng: { "ok": bool, "status": int, "data": Variant }
func fetch(path: String, method: int = HTTPClient.METHOD_GET, body: Dictionary = {}) -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var url = API_BASE + path
	var headers = ["Content-Type: application/json"]
	
	# Đính kèm Session Token nếu đã đăng nhập (sử dụng AuthManager Autoload)
	if AuthManager.get_token() != "":
		headers.append("X-Session-Token: " + AuthManager.get_token())
	
	var json_body = ""
	if method != HTTPClient.METHOD_GET and body.size() > 0:
		json_body = JSON.stringify(body)
		
	var err = http_request.request(url, headers, method, json_body)
	if err != OK:
		http_request.queue_free()
		return { "ok": false, "status": 0, "data": "Lỗi kết nối mạng: " + str(err) }
		
	# Đợi tín hiệu request_completed
	var result = await http_request.request_completed
	
	# result là một mảng: [result (int), response_code (int), headers (PackedStringArray), body (PackedByteArray)]
	var res_code = result[1]
	var res_body_bytes = result[3]
	
	http_request.queue_free()
	
	var data = null
	if res_body_bytes.size() > 0:
		var json = JSON.new()
		var parse_err = json.parse(res_body_bytes.get_string_from_utf8())
		if parse_err == OK:
			data = json.data
			
	var is_ok = (res_code >= 200 and res_code < 300)
	return { "ok": is_ok, "status": res_code, "data": data }

# ==============================================================================
# AUTH API
# ==============================================================================

func register(email:String, password:String, phone:String, grade:int, region:String, avatar:String) -> Dictionary:
	var payload = {
		"email": email,
		"password": password,
		"grade": grade,
		"region": region,
		"avatarUrl": avatar,
		"phone": phone
	}
	return await fetch("/api/users/register", HTTPClient.METHOD_POST, payload)

func login(email: String, password: String) -> Dictionary:
	var payload = {
		"email": email,
		"password": password
	}
	return await fetch("/api/users/login", HTTPClient.METHOD_POST, payload)

func logout() -> Dictionary:
	var payload = { "token": AuthManager.get_token() }
	var res = await fetch("/api/users/logout", HTTPClient.METHOD_POST, payload)
	AuthManager.clear_session()
	return res

# ==============================================================================
# GAMES API
# ==============================================================================

func get_games_by_map(map_id: int) -> Dictionary:
	return await fetch("/api/game/by-map/" + str(map_id))

func start_game(user_id: int, game_id: int) -> Dictionary:
	var payload = { "userId": user_id, "gameId": game_id }
	return await fetch("/api/game/start", HTTPClient.METHOD_POST, payload)

func get_questions(session_id: String) -> Dictionary:
	return await fetch("/api/game/" + session_id + "/questions")

func submit_answers(session_id: String, answers: Array) -> Dictionary:
	# answers: Array của Dictionary -> [{ "questionId": 1, "selectedAnswerId": 0 }, ...]
	var payload = { "answers": answers }
	return await fetch("/api/game/" + session_id + "/submit", HTTPClient.METHOD_POST, payload)

# ==============================================================================
# MAPPING CÁC API KHÁC THEO NHU CẦU...
# ==============================================================================
func get_maps() -> Dictionary:
	return await fetch("/api/maps")
	
func get_grammar_progress() -> Dictionary:
	return await fetch("/api/grammar/progress/me")
