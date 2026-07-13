@tool
extends LatticeComponent
class_name ServoBodyHolder

@export var servo_model: String = "SG90":
	get:
		return servo_model
	set(value):
		servo_model = value
		_update_servo_model_data()
var _servo_model_data = null

func _ready() -> void:
	_update_servo_model_data()

func _enter_tree() -> void:
	if get_parent() is Point:
		set_notify_transform(true)
		_recalculate_transform()
	else:
		set_notify_transform(false)

func _update_servo_model_data() -> void:
	var key = servo_model.strip_edges().to_upper()
	_servo_model_data = LatticeConstants.servo_data.get(key, null)
	
	if (_servo_model_data == null):
		print_rich("[color=red]Error:[/color] Servo model '" + servo_model + "' not registered!")
	queue_redraw()

func get_servo_bounding_box() -> Rect2:
	if _servo_model_data == null:
		return Rect2()
	
	var width = _servo_model_data['width']
	var height = _servo_model_data['height']
	var holes = _servo_model_data.get('holes', [])
	
	var half_w = width / 2.0
	var half_h = height / 2.0
	
	var critical_points: Array[Vector2] = [
		Vector2(-half_w, -half_h),
		Vector2(half_w, -half_h),
		Vector2(half_w, half_h),
		Vector2(-half_w, half_h)
	]
	
	for hole in holes:
		var r = hole.diameter / 2.0
		critical_points.append(hole.pos + Vector2(r, 0))
		critical_points.append(hole.pos + Vector2(-r, 0))
		critical_points.append(hole.pos + Vector2(0, r))
		critical_points.append(hole.pos + Vector2(0, -r))
	
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	for pt in critical_points:
		var rotated_pt = pt.rotated(rotation)
		min_x = min(min_x, rotated_pt.x)
		max_x = max(max_x, rotated_pt.x)
		min_y = min(min_y, rotated_pt.y)
		max_y = max(max_y, rotated_pt.y)
		
	return Rect2(min_x-2, min_y-2, max_x - min_x + 4, max_y - min_y + 4)

func _recalculate_transform() -> void:
	_bounding_box_rect = get_servo_bounding_box()
	queue_redraw()

func _draw() -> void:
	if (_servo_model_data == null): return
	
	var width = _servo_model_data['width']
	var height = _servo_model_data['height']
	var holes = _servo_model_data['holes']
	
	draw_rect(
		Rect2(-width/2, -height/2, width, height),
		Color.GREEN,
		false,
		1
	)
	
	for i in holes:
		draw_circle(
			i.pos,
			i.diameter / 2,
			Color.GREEN,
			false,
			1
		)
	
	var font = ThemeDB.get_default_theme().default_font
	const font_size = 3
	const align = HORIZONTAL_ALIGNMENT_LEFT
	
	draw_set_transform(Vector2(0, 0), -rotation, Vector2(1, 1))
	
	var text_size = font.get_string_size(servo_model, align, -1, font_size)
	draw_string(font, Vector2(-text_size.x/2, 0), servo_model, align, -1, font_size)
	
	if (LatticeConstants.debug_draw):
		draw_rect(get_bounding_box(), Color.BLUE, false, 0.5)
		
	draw_set_transform(Vector2.ZERO, 0)
