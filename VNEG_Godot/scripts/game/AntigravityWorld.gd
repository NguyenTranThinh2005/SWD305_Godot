extends Node2D
## VNEG_Godot/scripts/game/AntigravityWorld.gd
##
## Quản lý luồng hiển thị câu hỏi, tính điểm, gọi API nộp bài,
## và ra lệnh đảo ngược trọng lực vật lý cho Node Player.

@onready var ui_canvas: CanvasLayer = $UI
@onready var question_label: Label = $UI/QuestionBox/QuestionLabel
@onready var choices_box: VBoxContainer = $UI/QuestionBox/ChoicesBox
@onready var stars_label: Label = $UI/TopHUD/StarsLabel
@onready var hp_label: Label = $UI/TopHUD/HPLabel
@onready var timer_label: Label = $UI/TopHUD/TimerLabel

@onready var player: CharacterBody2D = $Player # Tham chiếu tới nhân vật

var timer_sec: float = 0.0
var current_question_index: int = 0
var is_game_over: bool = false
var gravity_flipped: bool = false

func _ready():
	_update_hud()
	if GameManager.game_questions.size() > 0:
		_show_question(0)
	else:
		question_label.text = "Lỗi: Không tìm thấy bộ câu hỏi!"

func _process(delta: float) -> void:
	if not is_game_over:
		timer_sec += delta
		var m = floor(timer_sec / 60.0)
		var s = int(timer_sec) % 60
		timer_label.text = str(m).pad_zeros(2) + ":" + str(s).pad_zeros(2)

func _update_hud() -> void:
	stars_label.text = "⭐ " + str(GameManager.stars)
	var hp_str = ""
	for i in range(GameManager.hp): hp_str += "♥️"
	hp_label.text = hp_str if GameManager.hp > 0 else "💀"

func _show_question(index: int) -> void:
	if index >= GameManager.game_questions.size():
		_end_game()
		return
		
	var q_data = GameManager.game_questions[index]
	var q_id = q_data.get("id", 0)
	var q_type = str(q_data.get("questionType", "")).to_lower()
	
	# 1. Determine Title (display_text)
	var display_text = ""
	var title_keys = ["data", "Data", "question", "title"]
	for k in title_keys:
		if q_data.has(k) and str(q_data[k]) != "" and str(q_data[k]) != "null":
			display_text = str(q_data[k])
			break
	if display_text == "": display_text = "Câu hỏi " + str(index + 1)
	
	# 2. Determine Hint (hint_text)
	var hint_text = ""
	var hint_keys = ["explanation", "Explanation", "hint", "description"]
	for k in hint_keys:
		if q_data.has(k) and str(q_data[k]) != "" and str(q_data[k]) != "null":
			hint_text = str(q_data[k])
			break
	
	var hint_str = ""
	if hint_text != "":
		hint_str = "\n💡 " + hint_text
		
	if display_text.begins_with("[") and display_text.ends_with("]"):
		# If it's a JSON string by mistake, clean it
		display_text = display_text.replace("[\"", "").replace("\"]", "").replace("\", \"", " / ")
		
	# Speical case for Drag & Drop
	if q_type == "drag_drop_sentence":
		display_text = "Sắp xếp các từ sau thành câu hoàn chỉnh:"
		
	question_label.text = "Câu " + str(index + 1) + ": " + display_text + hint_str
	
	print("[DEBUG AntigravityWorld] Question ID: ", q_id, " Type: ", q_type)
	print("[DEBUG AntigravityWorld] Title: ", display_text)
	print("[DEBUG AntigravityWorld] Hint: ", hint_text)
		
	# Xóa nút/Question UI cũ
	for child in choices_box.get_children():
		child.queue_free()
		
	var q_node : QuestionBase = null
	
	if q_type == "multiple_choice" or q_type == "":
		q_node = preload("res://scripts/ui/QuestionMultipleChoice.gd").new()
	elif q_type == "fill_blank":
		q_node = preload("res://scripts/ui/QuestionFillBlank.gd").new()
	elif q_type == "listen_choose":
		q_node = preload("res://scripts/ui/QuestionListenChoose.gd").new()
	elif q_type == "find_error":
		q_node = preload("res://scripts/ui/QuestionFindError.gd").new()
	elif q_type == "picture_guess":
		q_node = preload("res://scripts/ui/QuestionPictureGuess.gd").new()
	elif q_type == "drag_drop_sentence":
		q_node = preload("res://scripts/ui/QuestionDragDropSentence.gd").new()
	else:
		# Fallback
		q_node = preload("res://scripts/ui/QuestionMultipleChoice.gd").new()
		
	if q_node:
		choices_box.add_child(q_node)
		q_node.setup(q_data)
		q_node.answer_submitted.connect(func(is_correct, raw_ans):
			_on_answer_submitted(index, q_id, is_correct, raw_ans)
		)

func _on_answer_submitted(_q_index: int, q_id: int, is_correct: bool, raw_ans: Variant) -> void:
	if is_game_over: return
	
	# Lưu kết quả
	GameManager.record_answer(q_id, raw_ans, is_correct)
	
	if is_correct:
		_trigger_gravity_flip()
		
	_update_hud()
	
	if GameManager.hp <= 0:
		_end_game()
		return
		
	current_question_index += 1
	_show_question(current_question_index)

func _trigger_gravity_flip() -> void:
	gravity_flipped = !gravity_flipped
	PhysicsServer2D.area_set_param(get_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0, -1 if gravity_flipped else 1))
	if player and player.has_method("flip_gravity"):
		player.flip_gravity(gravity_flipped)

func _end_game() -> void:
	is_game_over = true
	question_label.text = "🎯 ĐANG GỬI KẾT QUẢ..."
	for child in choices_box.get_children():
		child.queue_free()
		
	var final_msg = "Bạn đã hoàn thành bài tập!"
	question_label.text = final_msg
	
	# Xây dựng nút thoát
	var btn_exit = Button.new()
	btn_exit.text = "Về Dashboard"
	btn_exit.disabled = true # Cấm bấm trong lúc gửi API
	choices_box.add_child(btn_exit)
	
	# Gọi API Submit
	var answers = GameManager.get_submission_data()
	var res = await API.submit_answers(GameManager.current_session_id, answers)
	
	if res["ok"] and typeof(res["data"]) == TYPE_DICTIONARY:
		var d = res["data"]
		final_msg = "Kết quả: " + str(d.get("score", 0)) + " điểm!\n"
		final_msg += "Chính xác: " + str(d.get("accuracy", 0)) + "%\n"
		final_msg += "Nhận được " + str(d.get("stars", 0)) + " ⭐ và " + str(d.get("coins", 0)) + " 🪙"
	else:
		final_msg = "Lỗi khi lưu kết quả lên Server.\nStars đạt được: " + str(GameManager.stars)
	
	question_label.text = final_msg
	
	btn_exit.disabled = false
	btn_exit.pressed.connect(func(): 
		# Reset gravity before leaving
		PhysicsServer2D.area_set_param(get_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0, 1))
		GameManager.clear_session()
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)
