@tool
extends Resource
class_name SvgElement

@export_enum("cut", "engrave", "none") var operation: String = "none"
@export var fill: String = "none"
@export var stroke: String = "#000000"
@export var stroke_width: float = 1.0

func to_svg_lines() -> Array[String]:
	return []
