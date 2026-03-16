extends PanelContainer

@onready var label_title = $MarginContainer/VBoxContainer/Title
@onready var label_value = $MarginContainer/VBoxContainer/Value

func setup(title: String, value: String, color: Color = Color.WHITE):
	label_title.text = title
	label_value.text = value
	label_value.add_theme_color_override("font_color", color)
