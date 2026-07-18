@tool
extends Resource
class_name SvgDocument

var image_size : Vector2

var elements: Array[SvgElement] = []

func serialize() -> String:
	var doc = []
	
	doc.append("<svg")
	doc.append("    xmlns=\"http://www.w3.org/2000/svg\"")
	doc.append("    viewBox=\"0 0 %.2f %.2f\"" % [ image_size.x, image_size.y ])
	doc.append("    width=\"%.2fmm\" height=\"%.2fmm\">" % [image_size.x, image_size.y ])
	
	for i in elements:
		var lines = i.to_svg_lines()
		for j in lines: doc.append("    " + j);
	
	doc.append("</svg>")
	return '\n'.join(doc);
