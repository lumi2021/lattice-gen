@tool
extends LatticeComponent
class_name ScrewArray

@export var screw_diameter_mm: float = 4
@export var step_mm: float = 20.0
@export var count: int = -1

@export_group("Guide Settings")
@export var guides: bool = true
@export var guide_diameter_mm: float = 2
@export var guide_offset_mm: float = 10
@export var hide_outer_guides: bool = false

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var length := 0.0
	
	if get_parent() is Point: length = get_parent().length
	if length <= 0: return

	var draw_count = _get_draw_count(length)
	var obstacle_boxes = _get_obstacle_bounding_boxes()
	
	var min_pos := Vector2.INF
	var max_pos := -Vector2.INF

	for i in range(draw_count):
		var x := i * step_mm
		var screw_pos := Vector2(x, 0)
		var screw_radius := screw_diameter_mm / 2.0
		
		if not _is_point_inside_obstacles(self.position + screw_pos, screw_radius, obstacle_boxes):
			draw_circle(screw_pos, screw_radius, Color.GREEN, false, 1)
			
			min_pos.x = min(min_pos.x, screw_pos.x - screw_radius)
			min_pos.y = min(min_pos.y, screw_pos.y - screw_radius)
			max_pos.x = max(max_pos.x, screw_pos.x + screw_radius)
			max_pos.y = max(max_pos.y, screw_pos.y + screw_radius)

		if guides:
			var is_outer_column = (i == 0 or i == draw_count - 1)
			if hide_outer_guides and is_outer_column: continue
			
			var offset := guide_offset_mm
			var guide_radius := guide_diameter_mm / 2.0

			var guide_positions = [
				Vector2(x - offset, -offset),
				Vector2(x + offset, -offset),
				Vector2(x - offset, offset),
				Vector2(x + offset, offset)
			]

			for guide_pos in guide_positions:
				if not _is_point_inside_obstacles(self.position + guide_pos, guide_radius, obstacle_boxes):
					draw_circle(guide_pos, guide_radius, Color.GREEN, false, 1)
					
					min_pos.x = min(min_pos.x, guide_pos.x - guide_radius)
					min_pos.y = min(min_pos.y, guide_pos.y - guide_radius)
					max_pos.x = max(max_pos.x, guide_pos.x + guide_radius)
					max_pos.y = max(max_pos.y, guide_pos.y + guide_radius)

	if min_pos != Vector2.INF and max_pos != -Vector2.INF:
		_bounding_box_rect = Rect2(min_pos, max_pos - min_pos)
	else:
		_bounding_box_rect = Rect2(-5, 5, 10, 10)

	if (LatticeConstants.debug_draw):
		draw_rect(get_bounding_box(), Color.BLUE, false, 0.5)

func _get_draw_count(length: float) -> int:
	var max_count: int = floor((length - position.x) / step_mm) + 1
	return min(count, max_count) if count > 0 else max_count

func _get_obstacle_bounding_boxes() -> Array[Rect2]:
	var bboxes: Array[Rect2] = []
	var parent = get_parent()
	if not parent:
		return bboxes
		
	for sibling in parent.get_children():
		if sibling == self or not sibling.has_method("get_bounding_box"): continue
			
		var local_bbox: Rect2 = sibling.get_bounding_box()
		var global_bbox = Rect2(sibling.position + local_bbox.position, local_bbox.size)
		bboxes.append(global_bbox)
		
	return bboxes

func _is_point_inside_obstacles(pos_in_parent: Vector2, radius: float, obstacles: Array[Rect2]) -> bool:
	for obstacle_bbox in obstacles:
		var detection_box = obstacle_bbox.grow(radius)
		if detection_box.has_point(pos_in_parent):
			return true
			
	return false
