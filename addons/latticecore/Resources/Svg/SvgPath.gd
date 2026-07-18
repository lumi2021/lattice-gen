@tool
extends SvgElement
class_name SvgPath

@export var transform: Transform2D = Transform2D.IDENTITY
@export var points: PackedVector2Array = PackedVector2Array()
@export var closed: bool = true

func to_svg_lines() -> Array[String]:
	if points.size() < 2: return []
	
	var start_p = transform * points[0]
	var path_data = "M %.3f %.3f" % [start_p.x, start_p.y]
	
	for i in range(1, points.size()):
		var p = transform * points[i]
		path_data += " L %.3f %.3f" % [p.x, p.y]
		
	if closed: path_data += " Z"
	
	return [
		'<path',
		'    d="%s" ' % [ path_data ],
		'    fill="%s"' % [ fill ],
		'    stroke="%s" stroke-width="%.1f"' % [ stroke, stroke_width ],
		'    stroke-linejoin="round"',
		'/>',
	]
