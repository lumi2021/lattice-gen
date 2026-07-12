@tool
extends Node2D
class_name LatticeComponent

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
