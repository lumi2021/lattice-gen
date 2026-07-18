@tool
extends Node2D
class_name Lattice

@export_group("Polygon Settings")
@export var closed: bool = false:
	set(val):
		closed = val
		queue_redraw()
@export var filled: bool = false:
	set(val):
		filled = val
		queue_redraw()
		
var cached_lattice_settings: LSettings = null
func get_lattice_settings() -> LSettings:
	if (cached_lattice_settings == null):
		if (get_parent().has_method("get_lattice_settings")):
			cached_lattice_settings = get_parent().get_lattice_settings()
	return cached_lattice_settings


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


func get_merged_polygons() -> Array[PackedVector2Array]:
	var points: Array[Point] = []
	for child in get_children():
		if child is Point:
			points.append(child)
			
	if points.size() == 0:
		return []

	var master_polygons: Array[PackedVector2Array] = []
	
	for i in range(points.size()):
		var p_curr = points[i]
		
		var joint_poly = _get_circle_polygon(p_curr.position, p_curr.radius_mm)
		master_polygons = _add_poly_to_union(master_polygons, joint_poly)
	
		if i < points.size() - 1:
			var p_next = points[i + 1]
			var dir = (p_next.position - p_curr.position).normalized()
			var normal = dir.orthogonal()
			
			var offset_curr = normal * p_curr.radius_mm
			var offset_next = normal * p_next.radius_mm
			
			var segment_poly = PackedVector2Array([
				p_curr.position + offset_curr,
				p_next.position + offset_next,
				p_next.position - offset_next,
				p_curr.position - offset_curr
			])
			master_polygons = _add_poly_to_union(master_polygons, segment_poly)
			
	for pt in points:
		for child in pt.get_children():
			if child.has_method("get_bounding_box"):
				var local_bbox: Rect2 = child.get_bounding_box()
				
				var margin = 0
				var corner_radius = 0
				
				if (get_lattice_settings() != null):
					if (child.housing_margin_mm_override != INF):
						margin = child.housing_margin_mm_override
					else: 
						margin = get_lattice_settings().component_casing_margin_mm
					
					if (child.housing_corner_radius_mm_override != INF):
						corner_radius = child.housing_corner_radius_mm_override
					else:
						corner_radius = get_lattice_settings().component_casing_corner_radius_mm
				
				var global_child_pos = pt.position + child.position 
				var bbox = Rect2(global_child_pos + local_bbox.position, local_bbox.size)
				
				var housing_poly = _get_rounded_rect_polygon(bbox, corner_radius)
				master_polygons = _add_poly_to_union(master_polygons, housing_poly)
				
	return master_polygons

func _draw() -> void:
	var master_polygons = get_merged_polygons()
	for poly in master_polygons:
		var draw_points = poly.duplicate()
		draw_points.append(draw_points[0])
		draw_polyline(draw_points, Color.RED, 1, false)

func _get_circle_polygon(center: Vector2, radius: float, segments: int = 32) -> PackedVector2Array:
	var poly = PackedVector2Array()
	for i in range(segments):
		var angle = i * TAU / segments
		poly.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return poly

func _get_rounded_rect_polygon(rect: Rect2, radius: float, corner_segments: int = 8) -> PackedVector2Array:
	var poly = PackedVector2Array()
	
	# Trava o raio para nunca bugar se o componente for muito pequeno
	radius = min(radius, min(rect.size.x / 2.0, rect.size.y / 2.0))
	
	var corners = [
		Vector2(rect.end.x - radius, rect.end.y - radius),           # Inferior Direito
		Vector2(rect.position.x + radius, rect.end.y - radius),      # Inferior Esquerdo
		Vector2(rect.position.x + radius, rect.position.y + radius), # Superior Esquerdo
		Vector2(rect.end.x - radius, rect.position.y + radius)       # Superior Direito
	]
	var start_angles = [0.0, PI * 0.5, PI, PI * 1.5]
	
	# Passa por cada quina desenhando um arco
	for i in range(4):
		var center = corners[i]
		var start_angle = start_angles[i]
		for j in range(corner_segments + 1):
			var angle = start_angle + (j / float(corner_segments)) * (PI / 2.0)
			poly.append(center + Vector2(cos(angle), sin(angle)) * radius)
			
	return poly

func _add_poly_to_union(poly_array: Array[PackedVector2Array], new_poly: PackedVector2Array) -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	var to_merge = new_poly
	
	for existing in poly_array:
		if Geometry2D.intersect_polygons(existing, to_merge).is_empty():
			result.append(existing)
			
		else:
			var unions = Geometry2D.merge_polygons(existing, to_merge)
			if unions.size() > 0:
				to_merge = unions[0]
				
				for i in range(1, unions.size()):
					result.append(unions[i])
					
	result.append(to_merge)
	return result
