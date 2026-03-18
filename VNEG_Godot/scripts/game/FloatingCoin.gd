extends Area2D
## FloatingCoin.gd — Thu thap sao bonus

signal coin_collected(bonus_stars)

var visual: ColorRect
var glow: ColorRect

func _ready():
	# Collision
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 18.0
	shape.shape = circle
	add_child(shape)

	# Glow effect
	glow = ColorRect.new()
	glow.color = Color(1.0, 0.85, 0.0, 0.15)
	glow.size = Vector2(36, 36)
	glow.position = Vector2(-18, -18)
	glow.rotation = PI / 4.0
	glow.pivot_offset = Vector2(18, 18)
	add_child(glow)

	# Visual diamond
	visual = ColorRect.new()
	visual.color = Color(1.0, 0.85, 0.0, 1.0)
	visual.size = Vector2(22, 22)
	visual.position = Vector2(-11, -11)
	visual.rotation = PI / 4.0
	visual.pivot_offset = Vector2(11, 11)
	add_child(visual)

	# Inner highlight
	var inner = ColorRect.new()
	inner.color = Color(1.0, 0.95, 0.5, 0.7)
	inner.size = Vector2(10, 10)
	inner.position = Vector2(-5, -5)
	inner.rotation = PI / 4.0
	inner.pivot_offset = Vector2(5, 5)
	add_child(inner)

	body_entered.connect(_on_body_entered)

	# Float animation
	var float_tween = create_tween().set_loops()
	float_tween.tween_property(self, "position:y", position.y - 12.0, 1.2).set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(self, "position:y", position.y + 12.0, 1.2).set_trans(Tween.TRANS_SINE)

	# Glow pulse
	var glow_tween = create_tween().set_loops()
	glow_tween.tween_property(glow, "modulate:a", 0.3, 0.8).set_trans(Tween.TRANS_SINE)
	glow_tween.tween_property(glow, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		coin_collected.emit(1)
		# Collect animation
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(queue_free)
