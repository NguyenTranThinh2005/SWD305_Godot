extends PanelContainer

@onready var game_name = $MarginContainer/HBoxContainer/GameName
@onready var score_label = $MarginContainer/HBoxContainer/Stats/Score
@onready var stars_label = $MarginContainer/HBoxContainer/Stats/Stars
@onready var accuracy_label = $MarginContainer/HBoxContainer/Stats/Accuracy
@onready var date_label = $MarginContainer/HBoxContainer/Date

func setup(data: Dictionary):
	game_name.text = data.get("game_name", "Unknown Game")
	score_label.text = "Score: %d" % data.get("score", 0)
	stars_label.text = "⭐ %d" % data.get("stars", 0)
	accuracy_label.text = "Acc: %d%%" % (data.get("accuracy", 0) * 100)
	
	# Simple date formatting if available, else use current time for demo
	date_label.text = data.get("completed_at", "Just now")
