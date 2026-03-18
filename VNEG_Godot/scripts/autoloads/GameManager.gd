extends Node
## GameManager.gd — Quản lý trạng thái ván game
## Lưu trữ session, câu hỏi, tính điểm, HP, thống kê.

signal hp_changed(new_hp: int)
signal score_changed(stars: int, coins: int)
signal question_answered(index: int, is_correct: bool)

var current_session_id: int = 0
var current_game_id: int = 0
var current_task_id: int = 0
var game_questions: Array = []
var answered_questions: Array = []

var hp: int = 3
var max_hp: int = 3
var coins: int = 0
var stars: int = 0
var correct_count: int = 0
var total_answered: int = 0
var streak: int = 0
var max_streak: int = 0
var time_started: float = 0.0

## Khởi tạo trạng thái game mới
func start_session(session_id: Variant, game_id: int, task_id: int = 0) -> void:
	current_session_id = int(session_id)
	current_game_id = game_id
	current_task_id = task_id
	game_questions.clear()
	answered_questions.clear()
	hp = 3
	max_hp = 3
	coins = 0
	stars = 0
	correct_count = 0
	total_answered = 0
	streak = 0
	max_streak = 0
	time_started = Time.get_ticks_msec() / 1000.0
	combo_multiplier = 1.0
	perfect_game = true

## Reset lại ván hiện tại (chơi lại)
func restart_session() -> void:
	hp = 3
	coins = 0
	stars = 0
	correct_count = 0
	total_answered = 0
	streak = 0
	combo_multiplier = 1.0
	perfect_game = true
	time_started = Time.get_ticks_msec() / 1000.0
	answered_questions.clear()

## Xóa trạng thái game
func clear_session() -> void:
	current_session_id = 0
	current_game_id = 0
	current_task_id = 0
	game_questions.clear()
	answered_questions.clear()

var combo_multiplier: float = 1.0
var perfect_game: bool = true

## Ghi nhận câu trả lời
func record_answer(question_id: int, raw_answer: Variant, is_correct: bool) -> void:
	answered_questions.append({
		"questionId": question_id,
		"selectedAnswer": raw_answer
	})
	total_answered += 1

	if is_correct:
		correct_count += 1
		streak += 1
		if streak > max_streak:
			max_streak = streak
		
		# Combo system: Increase multiplier every 3 correct answers
		combo_multiplier = min(1.0 + (floor(streak / 3.0) * 0.5), 3.0)
		
		# Advanced Scoring: Base 10 + (Streak * Combo)
		var reward_coins = int(10 * combo_multiplier + (streak * 2))
		coins += reward_coins
		
		if stars < 3 and correct_count % 3 == 0:
			stars += 1
	else:
		streak = 0
		combo_multiplier = 1.0
		hp = max(0, hp - 1)
		perfect_game = false

	hp_changed.emit(hp)
	score_changed.emit(stars, coins)
	question_answered.emit(total_answered - 1, is_correct)

## Tính accuracy phần trăm
func get_accuracy() -> float:
	if total_answered == 0: return 0.0
	return (float(correct_count) / float(total_answered)) * 100.0

## Tính thời gian chơi (giây)
func get_elapsed_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - time_started

## Tính điểm cuối cùng
func get_final_score() -> int:
	var base = correct_count * 20
	var streak_bonus = max_streak * 10
	var time_bonus = max(0, 60 - int(get_elapsed_time() / 5)) * 2
	var perfect_bonus = 500 if (perfect_game and total_answered > 0) else 0
	return int((base + streak_bonus + time_bonus + perfect_bonus) * combo_multiplier)

## Trả về data để submit về Backend
func get_submission_data() -> Array:
	return answered_questions
