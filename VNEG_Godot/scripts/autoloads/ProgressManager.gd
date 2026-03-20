extends Node
## VNEG_Godot/scripts/autoloads/ProgressManager.gd
##
## Quản lý tiến trình chơi (unlock map, unlock game blocks).
## Lưu trữ cục bộ thông qua ConfigFile.

const SAVE_PATH = "user://game_progress.cfg"

# Dữ liệu mẫu: { map_id: { cleared_games: [game_id1, game_id2], is_unlocked: bool } }
var progress_data: Dictionary = {}

func _ready():
	load_progress()

func load_progress():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		progress_data = config.get_value("progress", "data", {})
	else:
		# Khởi tạo mặc định nếu chưa có file save
		_initialize_default_progress()

func save_progress():
	var config = ConfigFile.new()
	config.set_value("progress", "data", progress_data)
	config.save(SAVE_PATH)

func _initialize_default_progress():
	# Map 1 (Sơ cấp) mặc định mở
	progress_data = {
		"1": { "is_unlocked": true, "cleared_games": [] },
		"2": { "is_unlocked": false, "cleared_games": [] },
		"3": { "is_unlocked": false, "cleared_games": [] }
	}
	save_progress()

func is_map_unlocked(map_id: int) -> bool:
	var m_id_str = str(map_id)
	if progress_data.has(m_id_str):
		return progress_data[m_id_str].get("is_unlocked", false)
	return false

func is_game_cleared(map_id: int, game_id: int) -> bool:
	var m_id_str = str(map_id)
	if progress_data.has(m_id_str):
		var cleared = progress_data[m_id_str].get("cleared_games", [])
		return int(game_id) in cleared
	return false

func get_cleared_count(map_id: int) -> int:
	var m_id_str = str(map_id)
	if progress_data.has(m_id_str):
		return progress_data[m_id_str].get("cleared_games", []).size()
	return 0

func can_exit_to_next_map(map_id: int) -> bool:
	return get_cleared_count(map_id) >= 6

func mark_game_cleared(map_id: int, game_id: int):
	var m_id_str = str(map_id)
	if not progress_data.has(m_id_str):
		progress_data[m_id_str] = { "is_unlocked": false, "cleared_games": [] }
	
	var cleared = progress_data[m_id_str].get("cleared_games", [])
	if not int(game_id) in cleared:
		cleared.append(int(game_id))
		progress_data[m_id_str]["cleared_games"] = cleared
		
		# Kiểm tra để unlock map tiếp theo nếu đủ 6 game (Sơ -> Trung -> Cao)
		if cleared.size() >= 6:
			_unlock_next_map(map_id)
		
		save_progress()

func _unlock_next_map(current_map_id: int):
	var next_map_id = current_map_id + 1
	var next_id_str = str(next_map_id)
	if progress_data.has(next_id_str):
		progress_data[next_id_str]["is_unlocked"] = true
		print("Chúc mừng! Đã mở khóa Map ID: ", next_map_id)
