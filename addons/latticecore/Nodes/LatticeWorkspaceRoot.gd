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


func generate_svg_from_lattices() -> String:
	# Inicializa o SVG com o tamanho do workspace
	var svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 %.2f %.2f\" width=\"%.2fmm\" height=\"%.2fmm\">\n" % [
		workspace_size_mm.x, workspace_size_mm.y, 
		workspace_size_mm.x, workspace_size_mm.y
	]
	
	# Passa por todos os filhos do root
	for child in get_children():
		if child is Lattice:
			var polygons = child.get_merged_polygons()
			
			# Guarda a transformação do nó Lattice (posição, rotação e escala)
			var lattice_transform = child.transform
			
			for poly in polygons:
				if poly.is_empty():
					continue
				
				# Aplica o transform ao primeiro ponto para o posicionar corretamente no espaço do Workspace
				var start_p = lattice_transform * poly[0]
				var path_data = "M %.3f %.3f" % [start_p.x, start_p.y]
				
				# Transforma e desenha linhas para os próximos pontos
				for i in range(1, poly.size()):
					var next_p = lattice_transform * poly[i]
					path_data += " L %.3f %.3f" % [next_p.x, next_p.y]
				
				# Fecha o caminho
				path_data += " Z"
				
				# Aplica as variáveis 'filled' configuradas no Lattice
				var fill_color = "none"
				if child.filled:
					fill_color = "#FF0000" # Vermelho
				var stroke_color = "#FF0000"
				var stroke_width = 1.0
				
				# Monta a tag <path>
				svg += "\t<path d=\"%s\" fill=\"%s\" stroke=\"%s\" stroke-width=\"%.1f\" stroke-linejoin=\"round\" />\n" % [
					path_data, fill_color, stroke_color, stroke_width
				]
				
	svg += "</svg>"
	return svg

func save_svg_to_file(file_path: String = "res://output.svg") -> void:
	var svg_content = generate_svg_from_lattices()
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(svg_content)
		file.close()
		print("SVG salvo com sucesso em: ", file_path)
	else:
		print("Erro ao tentar salvar o arquivo SVG.")
