@tool
extends EditorPlugin

const WORSPACE_SCENE := "res://scenes/workspace.tscn"
var editor_root := get_editor_interface().get_base_control()

var lattice_node_ids: Array[int] = []
#var lattice_nodes: Array[BaseLattice]:
	#get:
		#var valid_nodes: Array[BaseLattice] = []
		#var i = lattice_node_ids.size() - 1
		#while i >= 0:
			#var id = lattice_node_ids[i]
			#var obj = instance_from_id(id)
			#if is_instance_valid(obj) and obj is BaseLattice:
				#valid_nodes.append(obj as BaseLattice)
			#else:
				#lattice_node_ids.remove_at(i)
			#i -= 1
		#return valid_nodes

func _ready() -> void:
	_reshape_editor()
	_ensure_workspace()
	
	#get_tree().node_added.connect(_on_node_added_in_editor)
	#get_tree().node_removed.connect(_on_node_removed_in_editor)

#func _on_node_added_in_editor(node: Node) -> void:
	#var current_scene_root = get_editor_interface().get_edited_scene_root()
	#if not current_scene_root or node == current_scene_root: return
#
	#if current_scene_root.is_ancestor_of(node):
		#if node is BaseLattice:
			#var id = node.get_instance_id()
			#if not lattice_node_ids.has(id):
				#lattice_node_ids.append(id)
#
#func _on_node_removed_in_editor(node: Node) -> void:
	#var current_scene_root = get_editor_interface().get_edited_scene_root()
	#if not current_scene_root: return
	#
	#if current_scene_root.is_ancestor_of(node):
		#if node is BaseLattice:
			#var id = node.get_instance_id()
			#lattice_node_ids.erase(id)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.ctrl_pressed and event.alt_pressed and event.keycode == KEY_R:
			get_viewport().set_input_as_handled()
			EditorInterface.save_all_scenes()
			EditorInterface.restart_editor()

func _reshape_editor() -> void:
	var root = get_editor_interface().get_base_control()
	
	var buttons = root.find_child("EditorMainScreenButtons", true, false)
	if buttons:
		buttons.get_node("3D").hide()
		buttons.get_node("Game").hide()
		buttons.get_node("AssetLib").hide()
	
	var tabs = root.find_child("EditorSceneTabs", true, false)
	if tabs: tabs.hide().hide()
	
	for tab_bar in root.find_children("", "TabBar", true, false):
		for i in range(tab_bar.tab_count):
			var tab_title = tab_bar.get_tab_title(i)
			if tab_title.ends_with(".tscn") or tab_title.ends_with(".scn") or tab_title == "[empty]" or tab_title == "[vazia]":
				tab_bar.hide()
				break
	
	#var file_system_dock = EditorInterface.get_file_system_dock()
	#if file_system_dock: file_system_dock.hide()
	#
	#var settings = EditorInterface.get_editor_settings()
	#
	#settings.set_setting("editors/2d/grid_offset", Vector2(0, 0))
	#settings.set_setting("editors/2d/grid_step", Vector2(10, 10))
	#settings.set_setting("editors/2d/grid_major_subdivisions", 10)
	#
	##settings.set_setting("editors/2d/use_grid", true)
	#settings.set_setting("editors/2d/use_snap", true)
	#settings.set_setting("editors/2d/snap_pixel", true)
	#
	#var canvas_editor = root.find_child("*CanvasItemEditor*", true, false)
	#
	#if canvas_editor:
		#canvas_editor.set_meta("grid_offset", Vector2(0, 0))
		#canvas_editor.set_meta("grid_step", Vector2(10, 10))
		#canvas_editor.set_meta("grid_major_subdivisions", 10)
		#
		#canvas_editor.set_meta("use_snap", true)
		#canvas_editor.set_meta("use_grid", false)
		#canvas_editor.set_meta("snap_pixel", true)
		#
		#if canvas_editor.has_method("update_viewport"):
			#canvas_editor.call("update_viewport")
		#elif canvas_editor.has_node("Viewport"):
			#canvas_editor.get_node("Viewport").queue_redraw()
	

func _ensure_workspace():
	if !ResourceLoader.exists(WORSPACE_SCENE):
		
		var root := LatticeWorkspaceRoot.new()
		root.name = "Root";
		var scene := PackedScene.new()
		scene.pack(root)
		ResourceSaver.save(scene, WORSPACE_SCENE)

	get_editor_interface().open_scene_from_path(WORSPACE_SCENE)
	await get_tree().process_frame

	var workspace_root = get_editor_interface().get_edited_scene_root()

	if workspace_root == null:
		push_error("It was not possible to open scene in '%s'." % WORSPACE_SCENE)
		get_tree().quit(1)
		return

	if !(workspace_root is LatticeWorkspaceRoot):
		OS.alert(
			"Invalid project!\n\nThis plugin requires a project created by Lattice.\n" +
			"Please create a new project, install the Lattice plugin on it an then " +
			"reload the project.",
			"Lattice"
		)

		get_tree().quit(1)
		return
	
	get_editor_interface().set_main_screen_editor("2D")

func _build() -> bool:
	return false
