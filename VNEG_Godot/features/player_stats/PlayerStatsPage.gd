extends Control

@onready var stats_grid = %StatsGrid
@onready var history_list = %HistoryList
@onready var grammar_list = %GrammarList
@onready var accuracy_chart = %AccuracyChart
@onready var coins_chart = %CoinsChart

const STATS_CARD = preload("res://features/player_stats/StatsCard.tscn")
const HISTORY_ITEM = preload("res://features/player_stats/GameHistoryItem.tscn")
const GRAMMAR_ITEM = preload("res://features/player_stats/GrammarProgressItem.tscn")

func _ready():
	# First try to load from backend
	if AuthManager.is_logged_in():
		load_all_data()
	else:
		# Fallback for testing/unauthenticated
		load_mock_all()

func load_all_data():
	# Trong Godot 4, nếu hàm có await thì nó trả về kết quả ngay lập tức là một tín hiệu/trạng thái.
	# Để tránh lỗi Parser, chúng ta gọi await trực tiếp cho từng hàm.
	await load_player_stats_api()
	await load_game_history_api()
	await load_grammar_progress_api()

func load_player_stats_api():
	var res = await API.fetch("/api/users/me")
	if res.ok:
		var user = res.data.get("user", {})
		# Map API fields to UI cards
		var stats = [
			{"title": "XU TÍCH LŨY", "value": str(user.get("coins", 0)), "color": Color(1, 0.8, 0)},
			{"title": "CẤP ĐỘ", "value": str(user.get("grade", "N/A")), "color": Color(0.2, 0.7, 1)},
			{"title": "EMAIL", "value": user.get("email", "Unknown"), "color": Color(0.7, 0.7, 0.7)}
		]
		_render_stats_cards(stats)
	else:
		load_mock_stats()

func load_game_history_api():
	# Assuming endpoint GET /api/game/sessions/me
	var res = await API.fetch("/api/game/sessions/me")
	if res.ok and res.data is Array:
		_render_history_items(res.data)
		_update_charts(res.data)
	else:
		load_mock_history()

func load_grammar_progress_api():
	var res = await API.get_grammar_progress()
	if res.ok:
		var progress = res.data.get("progress", [])
		_render_grammar_list(progress)
	else:
		load_mock_grammar()

# ==========================================================
# RENDER HELPERS
# ==========================================================

func _render_stats_cards(stats: Array):
	for c in stats_grid.get_children(): c.queue_free()
	for s in stats:
		var card = STATS_CARD.instantiate()
		stats_grid.add_child(card)
		card.setup(s.title, s.value, s.color)

func _render_history_items(history: Array):
	for c in history_list.get_children(): c.queue_free()
	for h in history:
		var item = HISTORY_ITEM.instantiate()
		history_list.add_child(item)
		item.setup(h)
		await get_tree().process_frame

func _render_grammar_list(topics: Array):
	for c in grammar_list.get_children(): c.queue_free()
	for t in topics:
		var item = GRAMMAR_ITEM.instantiate()
		grammar_list.add_child(item)
		# API uses different keys than mock: correct, wrong
		item.setup(t.get("topicName", "Unknown"), t.get("correct", 0), t.get("wrong", 0))

func _update_charts(history: Array):
	var accuracy_data = []
	var coins_data = []
	for h in history:
		accuracy_data.append(h.get("accuracy", 0.0) * 100.0)
		coins_data.append(float(h.get("coins", 0)))
	
	accuracy_data.reverse()
	coins_data.reverse()
	
	accuracy_chart.update_data(accuracy_data)
	coins_chart.update_data(coins_data)

# ==========================================================
# MOCK FALLBACKS (Previously existing logic moved here)
# ==========================================================

func load_mock_all():
	load_mock_stats()
	load_mock_history()
	load_mock_grammar()

func load_mock_stats():
	var stats = [
		{"title": "XU TÍCH LŨY (MOCK)", "value": "12,450", "color": Color(1, 0.8, 0)},
		{"title": "ĐỘ CHÍNH XÁC TB", "value": "88%", "color": Color(0.2, 0.8, 0.2)}
	]
	_render_stats_cards(stats)

func load_mock_history():
	var history = [
		{"game_name": "Grammar Quiz #1", "score": 1500, "stars": 3, "accuracy": 0.95, "coins": 15, "completed_at": "Hôm nay"}
	]
	_render_history_items(history)
	_update_charts(history)

func load_mock_grammar():
	var topics = [{"topic": "Danh từ & Đại từ", "correct": 120, "wrong": 15}]
	_render_grammar_list(topics)

func _on_back_button_pressed():
	get_tree_change_scene_to_file("res://scenes/MainMenu.tscn")

# Helper for Godot 4 scene change
func get_tree_change_scene_to_file(path: String):
	get_tree().change_scene_to_file(path)
