@tool
extends Window
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# GDShedor
# https://github.com/CodeNameTwister/gdshedor/LICENSE
#
# author:	CodeNameTwister
# license:	Copyrights © 2026 by Twister. All rights reserved
# contact:	https://github.com/CodeNameTwister/gdshedor/issues
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
const FILE_DIALOG = preload("file_dialog.tscn")

@export var origin : CodeEdit
@export var processed : CodeEdit
@export var copy : Button
@export var select : Button
@export var process : Button
@export var close : Button

var _dialog : FileDialog = null

func _on_origin_changed() -> void:
	_change_ctrl(origin, processed)

func _on_processed_changed() -> void:
	_change_ctrl(processed, origin)
	
func _change_ctrl(f : CodeEdit, t : CodeEdit) -> void:	
	if f.has_meta(&"B") and f.get_meta(&"B"):
		f.set_meta(&"B", false)
		return
	
	var current_line : int = f.get_caret_line()
	
	if !f.has_meta(&"A") or current_line != f.get_meta(&"A"):
		f.set_meta(&"A", current_line)
		t.set_meta(&"B", true)
		t.set_caret_line(current_line, true)
		t.center_viewport_to_caret(0)
		
func _ready() -> void:
	if get_parent() == Engine.get_main_loop().root:
		return
	
	close_requested.connect(_on_hide)
	copy.pressed.connect(_on_copy)
	select.pressed.connect(_on_select)
	process.pressed.connect(_on_process)
	close.pressed.connect(_on_hide)
	
	origin.caret_changed.connect(_on_origin_changed)
	processed.caret_changed.connect(_on_processed_changed)
	
	
	var screen_index : int = DisplayServer.window_get_current_screen()
	var screen_size : Vector2 = DisplayServer.screen_get_size(screen_index)
	
	size = screen_size * 0.8
	
	move_to_center.call_deferred()
	
func res(o : Control) -> void:
	o .modulate = Color.GREEN
	o .create_tween().tween_property(o , "modulate", Color.WHITE, 0.5)
	
func _on_copy() -> void:
	res(copy)
	DisplayServer.clipboard_set(processed.text)
	EditorInterface.get_editor_toaster().push_toast("Copied to clipboard!", EditorToaster.SEVERITY_INFO)
	
func _on_select() -> void:
	res(select)
	
	if is_instance_valid(_dialog):
		_dialog.queue_free()
		
	_dialog = FILE_DIALOG.instantiate()
	_dialog.title = "Select a GDShader File"
	_dialog.filters = ["*.gdshader", "*.gdshaderinc"]
	_dialog.file_selected.connect(_open_toolbox)
	add_child(_dialog)
	
func _open_toolbox(file : String) -> void:
	if is_instance_valid(_dialog):
		_dialog.queue_free()
		
	set_src(file)
	
func set_src(src : String, process_required :bool = false) -> void:
	if !FileAccess.file_exists(src):
		printerr("Not valid file!")
		return
	src = FileAccess.get_file_as_string(src)
	origin.set_deferred(&"text", src)
	
	if process_required:
		process.call_deferred(&"emit_signal", &"pressed")
	
func _on_process() -> void:
	res(process)
	
	var x : Node = get_tree().get_first_node_in_group(&"GDShedor")
	if x and x.has_method(&"set_buffer"):
		if Engine.has_singleton(&"GDShedor"):
			var gd : Node = Engine.get_singleton(&"GDShedor")
			gd.notification(3164312)
			x.call(&"set_buffer", origin.text)
			gd.notification(2162314)
			
			update(gd.get_data())
			
			var err : int = gd.get_error()
			
			if err != 0:
				if err == -2:
					EditorInterface.get_editor_toaster().push_toast("[GDShedor] No option selected.".format([err]), EditorToaster.SEVERITY_INFO)
					print("[GDShedor] No option selected.".format([err]))
					return
				EditorInterface.get_editor_toaster().push_toast("[GDShedor] Error code: {0}".format([err]), EditorToaster.SEVERITY_WARNING)
				print("[GDShedor] Error Code {0}: It appears there was an error processing your shader; please check the syntax.".format([err]))

func update(txt: String):
	var cl : int = processed.get_caret_line()
	var cc : int = processed.get_caret_column()
	var sh : int = processed.scroll_horizontal
	var sv : float = processed.scroll_vertical
	
	origin.set_meta(&"B", true)
	if txt.is_empty():
		processed.text = origin.text
	else:
		processed.text = txt
	processed.set_caret_line(cl)
	processed.set_caret_column(cc)
	
	processed.scroll_horizontal = sh
	processed.scroll_vertical = sv
	
func _on_hide() -> void:
	hide()
	queue_free()
