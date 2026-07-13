@tool
extends Node2D
class_name LatticeComponent

var _bounding_box_rect := Rect2(-5, -5, 10, 10)

func _ready() -> void:
	set_notify_transform(true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED: _recalculate_transform()

func update_draw() -> void:
	for i in get_children(true): if (i is LatticeComponent): i.update_draw()
	queue_redraw()

func _recalculate_transform() -> void:
	if not is_inside_tree(): return
	
	var parent = get_parent() as Point
	if not parent or not parent.point_after: return
	
	set_notify_transform(false)
	
	var vector_to_next: Vector2 = parent.point_after.position - parent.position
	var max_distance: float = vector_to_next.length()
	
	var clamped_x: float = clampf(position.x, 0.0, max_distance)
	position = Vector2(clamped_x, 0.0)
	
	set_notify_transform(true)
	queue_redraw()

func get_bounding_box() -> Rect2:
	return _bounding_box_rect

func draw() -> void:
	if (!LatticeConstants.debug_draw): return
	draw_rect(get_bounding_box(), Color.BLUE, false, 0.5)
