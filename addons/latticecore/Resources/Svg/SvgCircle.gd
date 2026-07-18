@tool
extends SvgElement
class_name SvgCircle

@export var transform: Transform2D = Transform2D.IDENTITY
@export var center: Vector2 = Vector2.ZERO
@export var radius: float = 0.0

func to_svg_lines() -> Array[String]:
	if radius <= 0: return []
	
	var global_center = transform * center
	var scale = transform.get_scale()
	var global_radius = radius * max(scale.x, scale.y)
	
	return [
		'<circle',
		'    cx="%.3f" cy="%.3f"' % [ global_center.x, global_center.y ],
		'    r="%.3f"' % [ global_radius ],
		'    fill="%s" stroke="%s"' % [ fill, stroke ],
		'    stroke-width="%.1f"' % [ stroke_width ],
		'/>\n'
	]
