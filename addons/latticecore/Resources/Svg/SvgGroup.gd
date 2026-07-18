extends SvgElement
class_name SvgGroup

var elements : Array[SvgElement] = []
@export var label: String = ""

func to_svg_lines() -> Array[String]:
	var lines: Array[String] = []
	
	var tag = '<g'
	if (label != ''): tag += ' label="' + str(label) + '"'
	tag += '>'
	lines.append(tag)
	
	for i in elements:
		var l = i.to_svg_lines()
		for j in l: lines.append("    " + j)
	
	lines.append('</g>')
	return lines
