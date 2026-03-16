extends Control

enum ChartType { LINE, BAR }

@export var type: ChartType = ChartType.LINE
@export var line_color: Color = Color(0.2, 0.6, 1.0)
@export var fill_color: Color = Color(0.2, 0.6, 1.0, 0.2)
@export var data_points: Array[float] = []
@export var padding: float = 20.0

func _draw():
	if data_points.is_empty():
		return
		
	var size = get_size()
	var max_val = data_points.max()
	if max_val == 0: max_val = 1.0
	
	var step_x = (size.x - padding * 2) / (data_points.size() - 1 if data_points.size() > 1 else 1)
	
	match type:
		ChartType.LINE:
			_draw_line_chart(size, max_val, step_x)
		ChartType.BAR:
			_draw_bar_chart(size, max_val, step_x)

func _draw_line_chart(size: Vector2, max_val: float, step_x: float):
	var points = PackedVector2Array()
	for i in range(data_points.size()):
		var x = padding + i * step_x
		var y = size.y - padding - (data_points[i] / max_val) * (size.y - padding * 2)
		points.append(Vector2(x, y))
	
	# Draw fill
	if points.size() > 1:
		var fill_points = points.duplicate()
		fill_points.append(Vector2(points[-1].x, size.y - padding))
		fill_points.append(Vector2(points[0].x, size.y - padding))
		draw_colored_polygon(fill_points, fill_color)
	
	# Draw line
	if points.size() > 1:
		draw_polyline(points, line_color, 3.0, true)
	
	# Draw dots
	for p in points:
		draw_circle(p, 4.0, line_color)

func _draw_bar_chart(size: Vector2, max_val: float, step_x: float):
	var bar_width = step_x * 0.8
	for i in range(data_points.size()):
		var x = padding + i * step_x - bar_width / 2
		if data_points.size() == 1: x = size.x / 2 - bar_width / 2
		
		var h = (data_points[i] / max_val) * (size.y - padding * 2)
		var rect = Rect2(x, size.y - padding - h, bar_width, h)
		draw_rect(rect, line_color)

func update_data(new_data: Array):
	data_points.clear()
	for d in new_data:
		data_points.append(float(d))
	queue_redraw()
