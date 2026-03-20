extends Control
## VNEG_Godot/scripts/ui/MapQuestionPanel.gd
##
## Panel hiện lên khi Mario va chạm vào Block.
## Hiển thị 10 câu hỏi, tính điểm và cập nhật Progress nếu đạt >= 80%.

@onready var question_label: Label = $Panel/VBoxMain/QuestionLabel
@onready var options_container: VBoxContainer = $Panel/VBoxMain/Scroll/OptionsContainer
@onready var result_label: Label = $Panel/VBoxMain/ResultLabel
@onready var next_button: Button = $Panel/VBoxMain/NextButton
@onready var close_button: Button = $Panel/CloseButton

var current_map_id: int = 0
var current_game_id: int = 0
var questions: Array = []
var current_q_index: int = 0
var correct_count: int = 0

func _ready():
	hide()
	# Các tín hiệu pressed đã được kết nối sẵn trong file .tscn

# Khởi động phiên làm bài
func start_quiz(map_id: int, game_id: int):
	print("[Quiz DEBUG] Bắt đầu Game ID: ", game_id, " trên Map: ", map_id)
	current_map_id = map_id
	current_game_id = game_id
	current_q_index = 0
	correct_count = 0
	questions.clear()
	
	show()
	_clear_options()
	
	# Kiểm tra xem game này đã hoàn thành chưa (80%)
	if ProgressManager.is_game_cleared(map_id, game_id):
		question_label.text = "Bạn đã hoàn thành thử thách này với kết quả xuất sắc (>=80%). Hãy tiếp tục hành trình tới các khối gạch khác hoặc đi tới cuối bản đồ để qua map mới nhé!"
		close_button.show()
		return
		
	question_label.text = "Đang kết nối Server..."
	_clear_options()
	close_button.hide() # Ẩn nút X khi đang làm bài
	
	var user_id = int(AuthManager.current_user.get("id", 0))
	var start_res = await API.start_game(user_id, game_id)
	
	if start_res["ok"]:
		var session_id = int(start_res["data"].get("sessionId", 0))
		print("[Quiz DEBUG] Session ID mới: ", session_id)
		var q_res = await API.get_questions(session_id)
		if q_res["ok"] and q_res["data"].size() > 0:
			questions = q_res["data"]
			print("[Quiz DEBUG] Đã tải ", questions.size(), " câu hỏi.")
			_display_question()
		else:
			question_label.text = "Không có câu hỏi nào trong Game này (ID: " + str(game_id) + ")"
	else:
		question_label.text = "Lỗi kết nối: " + str(start_res.get("data", "Server offline?"))

func _display_question():
	if current_q_index >= questions.size():
		_show_final_result()
		return
		
	# Reset giao diện thông báo của câu trước
	result_label.hide()
	next_button.hide()
	
	var q_data = questions[current_q_index]
	var q_type = str(q_data.get("questionType", "")).to_lower()
	
	print("[Quiz DEBUG] Câu ", current_q_index, " Type: ", q_type)
	
	# Determine Title (display_text)
	var display_text = ""
	var title_keys = ["data", "Data", "question", "title", "content", "questionText", "text"]
	for k in title_keys:
		if q_data.has(k) and str(q_data[k]) != "" and str(q_data[k]) != "null":
			display_text = str(q_data[k])
			break
	if display_text == "": display_text = "Hãy hoàn thành câu hỏi bên dưới:"
	
	# Special case for Drag & Drop
	if q_type == "drag_drop_sentence":
		display_text = "Sắp xếp câu:"
	elif q_type == "picture_guess":
		display_text = "Nhìn tranh đoán chữ:"
	elif q_type == "listen_choose":
		display_text = "Nghe và chọn đáp án:"
	
	question_label.text = "Câu " + str(current_q_index + 1) + ": " + display_text
	_clear_options()
	
	# Instantiate specialized Question UI
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
		q_node = preload("res://scripts/ui/QuestionMultipleChoice.gd").new()
		
	if q_node:
		options_container.add_child(q_node)
		q_node.setup(q_data)
		# Tăng kích thước font cho dễ nhìn trong Panel 2D
		q_node.add_theme_constant_override("separation", 10)
		
		q_node.answer_submitted.connect(func(is_correct, _raw_ans):
			_on_answer_submitted_from_node(is_correct)
		)

func _on_answer_submitted_from_node(is_correct: bool):
	if is_correct:
		correct_count += 1
		result_label.text = "CHÍNH XÁC!"
		result_label.modulate = Color.GREEN
	else:
		result_label.text = "SAI RỒI!"
		result_label.modulate = Color.RED
	
	result_label.show()
	next_button.show()

func _clear_options():
	for child in options_container.get_children():
		child.queue_free()

func _on_answer_selected(is_correct: bool):
	if is_correct:
		correct_count += 1
		result_label.text = "CHÍNH XÁC!"
		result_label.modulate = Color.GREEN
	else:
		result_label.text = "SAI RỒI!"
		result_label.modulate = Color.RED
	
	result_label.show()
	next_button.show()
	# Disable buttons
	for child in options_container.get_children():
		if child is Button: child.disabled = true

func _on_next_pressed():
	current_q_index += 1
	_display_question()

func _show_final_result():
	var percent = (float(correct_count) / questions.size()) * 100
	var passed = percent >= 80.0
	
	var msg = "Kết quả: " + str(correct_count) + "/" + str(questions.size()) + " (" + str(percent) + "%)\n"
	if passed:
		msg += "CHÚC MỪNG! BẠN ĐÃ VƯỢT QUA"
		ProgressManager.mark_game_cleared(current_map_id, current_game_id)
		
		# Gọi lên InteractiveMap (ông nội của Panel này) để cập nhật visual gạch
		var map = get_parent().get_parent()
		if map and map.has_method("update_blocks"):
			map.update_blocks()
	else:
		msg += "TIẾC QUÁ! BẠN CẦN 80% ĐỂ HOÀN THÀNH."
	
	question_label.text = msg
	_clear_options()
	result_label.hide()
	next_button.hide()
	close_button.show()
	
	# Tự động tắt sau 3 giây nếu pass
	if passed:
		await get_tree().create_timer(3.0).timeout
		hide()
