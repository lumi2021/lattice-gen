@tool
extends Node2D
class_name LatticeWorkspaceRoot

@export var workspace_size_mm: Vector2 = Vector2(300, 400):
	get: return workspace_size_mm
	set(value):
		workspace_size_mm = value
		queue_redraw()

@export var lattice_settings: LSettings = LSettings.new()
func get_lattice_settings() -> LSettings:
	return lattice_settings

func _ready() -> void:
	set_notify_transform(true)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		position = Vector2.ZERO
		rotation = 0

func _draw() -> void:
	draw_rect(
		Rect2(0, 0, workspace_size_mm.x, workspace_size_mm.y),
		Color.PURPLE,
		false,
		1
	)


func generate_svg_from_lattices() -> SvgDocument:
	var svgDoc = SvgDocument.new()
	svgDoc.image_size = workspace_size_mm
	
	for i in get_children():
		if i.has_method("to_svg"):
			svgDoc.elements.append(i.to_svg())
	
	return svgDoc

func save_svg_to_file(file_path: String = "res://output.svg") -> void:
	var svg_document = generate_svg_from_lattices()
	var svg_content = svg_document.serialize()
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(svg_content)
		file.close()
		print("Sucessfully saved SVG in : ", file_path)
		
	else:
		push_error("Error while trying to save SVG.")
