extends VBoxContainer

@onready var topic_label = $Header/Topic
@onready var ratio_label = $Header/Ratio
@onready var progress_bar = $ProgressBar

func setup(topic: String, correct: int, wrong: int):
	topic_label.text = topic
	var total = correct + wrong
	var percentage = (float(correct) / total * 100) if total > 0 else 0.0
	
	ratio_label.text = "%d Correct / %d Wrong" % [correct, wrong]
	progress_bar.value = percentage
	
	# Color progress bar based on mastery
	var style_box = progress_bar.get_theme_stylebox("fill").duplicate()
	if percentage >= 80:
		style_box.bg_color = Color(0.2, 0.8, 0.2)
	elif percentage >= 50:
		style_box.bg_color = Color(0.8, 0.8, 0.2)
	else:
		style_box.bg_color = Color(0.8, 0.2, 0.2)
	progress_bar.add_theme_stylebox_override("fill", style_box)
