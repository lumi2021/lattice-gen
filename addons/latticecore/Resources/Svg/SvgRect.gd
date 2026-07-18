@tool
extends SvgElement
class_name SVGRect

@export var transform: Transform2D = Transform2D.IDENTITY
@export var rect: Rect2 = Rect2()

func to_svg_lines() -> Array[String]:
	if rect.size == Vector2.ZERO: return []
	
	var points = [
		transform * rect.position,
		transform * Vector2(rect.end.x, rect.position.y),
		transform * rect.end,
		transform * Vector2(rect.position.x, rect.end.y)
	]
	
	var path_data = "M %.3f %.3f L %.3f %.3f L %.3f %.3f L %.3f %.3f Z" % [
		points[0].x, points[0].y,
		points[1].x, points[1].y,
		points[2].x, points[2].y,
		points[3].x, points[3].y
	]
	
	return [
		'<path',
		'    d="%s"' % [ path_data ],
		'    fill="%s"' % [ fill ],
		'    stroke="%s" stroke-width="%.1f"' % [ stroke, stroke_width ],
		'    stroke-linejoin="round"',
		'/>\n',
	]
