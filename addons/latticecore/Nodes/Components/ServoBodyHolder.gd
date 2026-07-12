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
	draw_set_transform(Vector2.ZERO, 0)
