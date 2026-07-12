@tool
extends Node2D
class_name Lattice

func _init() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED: _on_tree_reordered()

func _process(delta: float) -> void:
	queue_redraw()
	for child in get_children():
		var current_component = child as LatticeComponent
		if not current_component: continue
		
		current_component.update_draw()

func _on_scale_changed(new_scale: Vector2):
	pass

func _get_lattice_rect() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2.ZERO)

func _draw() -> void:
	var last_component: Point = null
	
	for child in get_children():
		var current_component = child as Point
		if not current_component: continue
		
		if last_component != null:
			var dir: Vector2 = (current_component.position - last_component.position).normalized()
			
			var normal: Vector2 = dir.orthogonal()
			
			var offset_last: Vector2 = normal * last_component.radius_mm
			var offset_curr: Vector2 = normal * current_component.radius_mm
			
			draw_line(
				last_component.position + offset_last,
				current_component.position + offset_curr,
				Color.RED,
				1
			)
			
			draw_line(
				last_component.position - offset_last,
				current_component.position - offset_curr,
				Color.RED,
				1
			)
		
		last_component = current_component

func _on_child_entered_tree(node: Node) -> void:
	if not is_instance_of(node, LatticeComponent):
		print_rich("[color=red]Error:[/color] Node '" + node.name + "' is not a lattice component!")
		
		remove_child.call_deferred(node)
		node.queue_free()
		notify_property_list_changed.call_deferred()

func _on_tree_reordered() -> void:
	var last_point: Point = null
	
	for child in get_children():
		var current_point = child as Point
		if not current_point: continue
	
		current_point.point_before = last_point
		if last_point != null: last_point.point_after = current_point
	
		last_point = current_point
	
	if last_point != null: last_point.point_after = null
	
	for child in get_children():
		if child is Point:
			child.notification(NOTIFICATION_TRANSFORM_CHANGED)
