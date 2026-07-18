extends SvgElement
class_name SvgComment

var content: String = ""

func to_svg_lines() -> Array[String]:
	return [ '<!-- %s -->' % content ]
