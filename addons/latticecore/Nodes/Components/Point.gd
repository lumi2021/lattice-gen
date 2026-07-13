@tool
extends LatticeComponent
class_name Point

var point_before : Point = null
var point_after: Point = null

@export var radius_mm: int = 10
var length: int = 0

func _draw() -> void:
	if (!LatticeConstants.debug_draw): return
	draw_circle(Vector2(0, 0), radius_mm, Color.BLUE, false, 0.5)

func _recalculate_transform() -> void:
	if not is_inside_tree(): return
	
	var old_rotation = rotation
	
	set_notify_transform(false)
	
	if point_after != null:
		var direction: Vector2 = point_after.position - position
		
		rotation = direction.angle()
		length = direction.length()
	else:
		rotation = 0.0
		length = 0.0
		
		
	set_notify_transform(true)
	
	if not is_equal_approx(rotation, old_rotation):
		for child in get_children():
			child.notification(NOTIFICATION_TRANSFORM_CHANGED)
		
	if (point_before != null): point_before.call_deferred("_recalculate_transform")
