@tool
extends EditorPlugin

const WORSPACE_SCENE := "res://scenes/workspace.tscn"
const LATTICE_CONSTANTS_SINGLETON_NAME := "LatticeConstants"
const LATTICE_CONSTANTS_SINGLETON_PATH := "res://addons/latticecore/Singletons/LatticeConstants.gd"

var lattice_debug_toggle_button: Button
var export_button: Button
var export_dialog: AcceptDialog

var current_workspace: LatticeWorkspaceRoot


func _enter_tree() -> void:
	add_autoload_singleton(
		LATTICE_CONSTANTS_SINGLETON_NAME,
		LATTICE_CONSTANTS_SINGLETON_PATH
	)

	_setup_editor()

	get_editor_interface().get_selection().selection_changed.connect(_selection_changed)


func _exit_tree() -> void:
	remove_autoload_singleton(LATTICE_CONSTANTS_SINGLETON_NAME)

	if lattice_debug_toggle_button:
		remove_control_from_container(
			EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU,
			lattice_debug_toggle_button
		)
		lattice_debug_toggle_button.queue_free()

	if export_button:
		remove_control_from_container(
			EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU,
			export_button
		)
		export_button.queue_free()

	if export_dialog:
		export_dialog.queue_free()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.ctrl_pressed and event.alt_pressed and event.keycode == KEY_R:
			get_viewport().set_input_as_handled()
			EditorInterface.save_all_scenes()
			EditorInterface.restart_editor()


func _setup_editor() -> void:
	var root = get_editor_interface().get_base_control()

	var buttons = root.find_child("EditorMainScreenButtons", true, false)
	if buttons:
		buttons.get_node("3D").hide()
		buttons.get_node("Game").hide()
		buttons.get_node("AssetLib").hide()

	lattice_debug_toggle_button = Button.new()
	lattice_debug_toggle_button.text = "Debug Draw"
	lattice_debug_toggle_button.toggle_mode = true
	lattice_debug_toggle_button.flat = true
	lattice_debug_toggle_button.button_pressed = _get_debug_draw_state()
	lattice_debug_toggle_button.toggled.connect(_on_button_toggled)

	_update_button_style()

	add_control_to_container(
		EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU,
		lattice_debug_toggle_button
	)

	export_button = Button.new()
	export_button.text = "Export"
	export_button.visible = false
	export_button.pressed.connect(_on_export_pressed)

	add_control_to_container(
		EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU,
		export_button
	)

	export_dialog = AcceptDialog.new()
	export_dialog.title = "Export"

	var label := Label.new()
	label.text = "Export workspace?"
	export_dialog.add_child(label)
	
	export_dialog.confirmed.connect(_export_dialog_confirmed)
	export_dialog.canceled.connect(_export_dialog_canceled)
	root.add_child(export_dialog)


func _selection_changed() -> void:
	current_workspace = null

	var selection := get_editor_interface().get_selection().get_selected_nodes()

	if selection.size() == 1 and selection[0] is LatticeWorkspaceRoot:
		current_workspace = selection[0]

	export_button.visible = current_workspace != null


func _on_export_pressed() -> void:
	export_dialog.popup_centered()


func _on_button_toggled(button_pressed: bool) -> void:
	_set_debug_draw_state(button_pressed)
	_update_button_style()

	var edited_root = get_editor_interface().get_edited_scene_root()
	if edited_root:
		edited_root.propagate_call("queue_redraw")


func _update_button_style() -> void:
	if not lattice_debug_toggle_button:
		return

	if lattice_debug_toggle_button.button_pressed:
		lattice_debug_toggle_button.self_modulate = Color.GREEN
	else:
		lattice_debug_toggle_button.self_modulate = Color.RED


func _get_debug_draw_state() -> bool:
	var script = load(LATTICE_CONSTANTS_SINGLETON_PATH) as Script

	if script and script.has_meta("debug_draw_state"):
		return script.get_meta("debug_draw_state")

	return false
func _set_debug_draw_state(value: bool) -> void:
	var script = load(LATTICE_CONSTANTS_SINGLETON_PATH) as Script

	if script:
		script.set_meta("debug_draw_state", value)
		ResourceSaver.save(script, LATTICE_CONSTANTS_SINGLETON_PATH)

	var tree := get_tree()

	if tree:
		var root := tree.root

		if root.has_node(LATTICE_CONSTANTS_SINGLETON_NAME):
			var singleton = root.get_node(LATTICE_CONSTANTS_SINGLETON_NAME)

			if "debug_draw" in singleton:
				singleton.debug_draw = value

func _export_dialog_confirmed() -> void:
	export_dialog.hide()
	if (current_workspace != null):
		current_workspace.save_svg_to_file();
	
func _export_dialog_canceled() -> void:
	export_dialog.hide()

func _build() -> bool:
	return false
