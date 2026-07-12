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

func _draw() -> void:
	var length := 0.0
	
	if get_parent() is Point:
		length = get_parent().length

	if length <= 0:
		return

	var max_count: int = floor((length - position.x) / step_mm) + 1
	var draw_count: int = min(count, max_count) if count > 0 else max_count

	for i in range(draw_count):
		var x := i * step_mm

		draw_circle(
			Vector2(x, 0),
			screw_diameter_mm / 2,
			Color.GREEN,
			false, 1
		)

		if guides:
			var offset := guide_offset_mm

			var guide_positions = [
				Vector2(x - offset, -offset),
				Vector2(x + offset, -offset),
				Vector2(x - offset, offset),
				Vector2(x + offset, offset)
			]

			for guide_pos in guide_positions:
				draw_circle(
					guide_pos,
					guide_diameter_mm / 2,
					Color.GREEN,
					false, 1
				)
