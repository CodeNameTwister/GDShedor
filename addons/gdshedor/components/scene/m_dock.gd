@tool
extends VBoxContainer
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# GDShedor
# https://github.com/CodeNameTwister/gdshedor/LICENSE
#
# author:	CodeNameTwister
# license:	Copyrights © 2026 by Twister. All rights reserved
# contact:	https://github.com/CodeNameTwister/gdshedor/issues
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
const VERSION : String = "1.0"
const SETTING : String = "SETTINGS"
const NSHELUDE : int = 3164312
const RESET : float = 5.0

#region __REF__
@export var toolbox : Button = null
@export var process_export_check : CheckBox = null
@export var obfuscate_symbols_check : CheckBox = null
@export var strip_commentary_check : CheckBox = null
@export var strip_lines_check : CheckBox = null
@export var remove_unused_uniforms_check : CheckBox = null
@export var remove_unused_functions_check : CheckBox = null
@export var replace_constants_check : CheckBox = null
@export var target_obfuscation_length : SpinBox = null
@export var header_text_edit : TextEdit = null
@export var footer_text_Edit : TextEdit = null
@export var prefix_line : LineEdit = null
@export var custom_names_path : LineEdit = null
@export var custom_locked_path : LineEdit = null
@export var select_file_uniforms : Button = null
@export var select_file_locked : Button = null
@export var no_test_check_button : Button = null
@export var no_preserve_shaderinc : Button = null
@export var enable_custom_symbol_names : CheckBox = null
@export var enable_custom_locked_names : CheckBox = null
@export var embed_shadering : CheckBox = null
@export var custom_seed : SpinBox = null
@export var reset_button : Button = null
#endregion

var _dlt : float = 0.0
var _save : bool = false
var _buffer : String = ""
var _tbox : Node = null
var _dialog : FileDialog = null

var _hfile_names : int = 0
var _custom_fnames : Dictionary = {}
var _custom_names : Dictionary = {}

var _hfile_locks : int = 0
var _custom_flocks : Dictionary = {}
var _custom_locks : Dictionary = {}

var _buffer_locks : PackedStringArray = []
var _buffer_names : Dictionary = {}
	
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
### Allow obfuscation process on export.
func is_export_enabled() -> bool:
	return process_export_check.button_pressed
	
### Obfuscate all symbols, example: my_custom_color >> _xR30	
func is_obfuscate_symbols_enabled() -> bool:
	return obfuscate_symbols_check.button_pressed
	
### Strip all comments like { // and /* */ }
func is_strip_commentary_enabled() -> bool:
	return strip_commentary_check.button_pressed
	
### Try make code all in inline.
func is_strip_lines_enabled() -> bool:
	return strip_lines_check.button_pressed
	
### Remove unused uniforms.
func is_remove_unused_uniform_enabled() -> bool:
	return remove_unused_uniforms_check.button_pressed
	
### Remove all u	nused functions, you must disable this if you shader is type a chunk like .shadering
func is_remove_unused_functions_enabled() -> bool:
	return remove_unused_functions_check.button_pressed
	
### Disable check shader after be processed.
func is_no_preserve_shaderinc() -> bool:
	return no_preserve_shaderinc.button_pressed
	
### Disable check shader after be processed.
func is_no_test_check() -> bool:
	return no_test_check_button.button_pressed
	
### Remove constant and replace all constants used by the constants values.	
func is_replace_constants() -> bool:
	return replace_constants_check.button_pressed
	
### Embed shaderincr.
func is_require_embed_shadering() -> bool:
	return embed_shadering.button_pressed
	
### Length of obfuscation token, example: Hello -> Length 5: rwqhx | Length: 10: edfhgobvco
func get_target_obfuscation_length() -> int:
	return target_obfuscation_length.value
	
### Custom header on top of you shader. 
func get_header_text() -> String:
	return header_text_edit.text
	
### Prefix for obfuscatio tokens.
func get_prefix_text() -> String:
	return prefix_line.text
	
### Custom footer of you shader. 
func get_footer_text() -> String:
	return footer_text_Edit.text
	
### You own custom obfuscation names.
func get_custom_names() -> Dictionary:
	if enable_custom_symbol_names.button_pressed:
		var ctime : int = _get_cn_filetime()
		if _hfile_names != ctime:
			_hfile_names = ctime
			_custom_fnames.clear()
			
			if FileAccess.file_exists(custom_names_path.text):
				for l : String in FileAccess.get_file_as_string(custom_names_path.text).split("\n", false):
					var sp : PackedStringArray = l.split(" ", false)
					if sp.size() > 1:
						var k : String = sp[0].strip_edges()
						var v : String = sp[1].strip_edges()
						
						if k.is_empty() or v.is_empty():
							continue
							
						_custom_fnames[StringName(k)] = StringName(v)
						
				_update_buffer_names()
		return _buffer_names
	return {}
	
### Use custom keys names.
func enable_use_custom_names(enable : bool) -> void:
	enable_custom_symbol_names.button_pressed = enable
	
### Use custom locks.	
func enable_use_custom_locks(enable : bool) -> void:
	enable_custom_locked_names.button_pressed = enable

### You own custom locked path.	
func get_custom_locked() -> PackedStringArray:
	if enable_custom_locked_names.button_pressed:
		var ctime : int = _get_cl_filetime()
		if _hfile_locks != ctime:
			_hfile_locks = ctime
			_custom_flocks.clear()
			if FileAccess.file_exists(custom_locked_path.text):
				for l : String in FileAccess.get_file_as_string(custom_locked_path.text).split("\n", false):
					for s : String in l.split("\n", false):
						s = s.strip_edges()
						
						if s.is_empty():
							continue
							
						_custom_flocks[StringName(s)] = true
				_update_buffer_locks()
				
		return _buffer_locks
	return []

### You own seed.	
func get_custom_seed() -> int:
	return custom_seed.value
	
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

func set_custom_names(cnames : Dictionary) -> void:
	var tmp : Dictionary = {}
	_custom_names.clear()
	
	for x : Variant in tmp.keys():
		_custom_names[StringName(str(tmp[x]))] = StringName(str(tmp[x]))
		
	_update_buffer_names()
		
func set_custom_locks(clocks : PackedStringArray) -> void:
	for x : String in clocks:
		_custom_locks[StringName(x)] = true
		
	_update_buffer_locks()
	
func _update_buffer_names() -> void:
	_buffer_names.clear()
	
	for x : StringName in _custom_fnames.keys():
		_buffer_names[x] = _custom_fnames[x]
		
	for x : StringName in _custom_names.keys():
		_buffer_names[x] = _custom_names[x]

func _update_buffer_locks() -> void:
	var tmp : Dictionary = {}
	_buffer_locks.clear()
	
	for x : StringName in _custom_flocks.keys():
		tmp[x] = true
		
	for x : StringName in _custom_locks.keys():
		tmp[x] = true
	
	for x : StringName in tmp.keys():
		_buffer_locks.append(x)
	
func set_buffer(buff : String) -> void:
	_buffer = buff
	
func get_buffer() -> String:
	return _buffer

func _select_uniforms() -> void:
	if is_instance_valid(_dialog):
		_dialog.queue_free()
		
	
	var path : String = get_script().resource_path
	var FILE_DIALOG : PackedScene = ResourceLoader.load(path.get_base_dir().path_join("file_dialog.tscn"))
	_dialog = FILE_DIALOG.instantiate()
	
	add_child(_dialog)
	
	_dialog.popup_centered()
	_dialog.file_selected.connect(_on_confirm.bind(custom_names_path))


func _get_cn_filetime() -> int:
	if FileAccess.file_exists(custom_names_path.text):
		return FileAccess.get_modified_time(custom_names_path.text)
	return 0
	
	
func _get_cl_filetime() -> int:
	if FileAccess.file_exists(custom_locked_path.text):
		return FileAccess.get_modified_time(custom_locked_path.text)
	return 0

	
func _select_locked() -> void:
	if is_instance_valid(_dialog):
		_dialog.queue_free()
		
	
	var path : String = get_script().resource_path
	var FILE_DIALOG : PackedScene = ResourceLoader.load(path.get_base_dir().path_join("file_dialog.tscn"))
	_dialog = FILE_DIALOG.instantiate()
	
	add_child(_dialog)
	
	_dialog.popup_centered()
	_dialog.file_selected.connect(_on_confirm.bind(custom_locked_path))
	
func _on_confirm(p : String, o : LineEdit) -> void:
	if is_instance_valid(_dialog):
		_dialog.queue_free()
		
	if FileAccess.file_exists(p):
		o.text = p
	else:
		o.text = ""
	o.text_changed.emit(o.text)

func _initialize() -> void:
	process_export_check.button_pressed = false
	obfuscate_symbols_check.button_pressed = true
	strip_commentary_check.button_pressed = false
	strip_lines_check.button_pressed = false
	remove_unused_functions_check.button_pressed = false
	remove_unused_uniforms_check.button_pressed = false
	replace_constants_check.button_pressed = false
	target_obfuscation_length.value = 5
	header_text_edit.text = ""
	footer_text_Edit.text = ""
	prefix_line.text = ""
	custom_names_path.text = "res://addons/gdshedor/user/custom_uniform_names.txt"
	custom_locked_path.text = "res://addons/gdshedor/user/custom_locked_symbols.txt"
	no_test_check_button.button_pressed = false
	no_preserve_shaderinc.button_pressed = false
	enable_custom_symbol_names.button_pressed = false
	enable_custom_locked_names.button_pressed = false
	embed_shadering.button_pressed = false
	custom_seed.value = 0

func _ready() -> void:
	var label : Label = get_child(0)
	set_process(false)
	
	label.text = "GDShedor v{0}".format([VERSION])
	toolbox.pressed.connect(open_toolbox)
	
	_initialize()
	_setup()
	
	select_file_uniforms.pressed.connect(_select_uniforms)
	select_file_locked.pressed.connect(_select_locked)
	reset_button.pressed.connect(_on_reset)
	
	_connect(process_export_check, &"process_export_check", &"pressed", &"button_pressed", true)
	_connect(obfuscate_symbols_check, &"obfuscate_symbols_check", &"pressed", &"button_pressed", true)
	_connect(strip_commentary_check, &"strip_commentary_check", &"pressed", &"button_pressed", true)
	_connect(strip_lines_check, &"strip_lines_check", &"pressed", &"button_pressed", true)
	_connect(remove_unused_uniforms_check, &"remove_unused_uniforms_check", &"pressed", &"button_pressed", true)
	_connect(remove_unused_functions_check, &"remove_unused_functions_check", &"pressed", &"button_pressed", true)
	_connect(replace_constants_check, &"replace_constants_check", &"pressed", &"button_pressed", true)
	_connect(target_obfuscation_length, &"target_obfuscation_length", &"value_changed", &"value")
	_connect(header_text_edit, &"header_text_edit", &"text_changed", &"text", true)
	_connect(footer_text_Edit, &"footer_text_Edit", &"text_changed", &"text", true)
	_connect(prefix_line, &"prefix_line", &"text_changed", &"text")
	_connect(custom_names_path, &"custom_names_path", &"text_changed", &"text")
	_connect(custom_locked_path, &"custom_locked_path", &"text_changed", &"text")
	_connect(no_test_check_button, &"no_test_check_button", &"pressed", &"button_pressed", true)
	_connect(no_preserve_shaderinc, &"no_preserve_shaderinc", &"pressed", &"button_pressed", true)
	_connect(enable_custom_symbol_names, &"enable_custom_symbol_names", &"pressed", &"button_pressed", true)
	_connect(enable_custom_locked_names, &"enable_custom_locked_names", &"pressed", &"button_pressed", true)
	_connect(embed_shadering, &"embed_shadering", &"pressed", &"button_pressed", true)
	_connect(custom_seed, &"custom_seed", &"value_changed", &"value")

func _on_reset() -> void:
	if Engine.has_singleton(&"GDShedor"):
		Engine.get_singleton(&"GDShedor").notification(NSHELUDE)
		EditorInterface.get_editor_toaster().push_toast("[GDShedor] Reseted all internal data.", EditorToaster.SEVERITY_INFO)
	else:
		EditorInterface.get_editor_toaster().push_toast("[GDShedor] Error, not full loaded plugin!", EditorToaster.SEVERITY_WARNING)

func _connect(o : Object, i: StringName, c : StringName, p : StringName, v : bool = false) -> void:
	if v:
		o.connect(c, reply.bind(null, self, i, p))
	else:
		o.connect(c, reply.bind(self, i, p))
	
func reply(__ : Variant, s : Node, o : StringName, p : StringName) -> void:
	if !is_instance_valid(s):
		return
	
	for x : Node in get_tree().get_nodes_in_group(&"GDShedor"):
		if x != s:
			var v : Variant = x.get(o)
			if v is Node:
				if v.get(p) != null:
					v.set(p, s.get(o).get(p))
					
	save_settings()
	
func open_toolbox() -> void:
	if is_instance_valid(_dialog):
		_dialog.queue_free()
		_dialog = null
		
	var path : String = get_script().resource_path
	var FILE_DIALOG : PackedScene = ResourceLoader.load(path.get_base_dir().path_join("file_dialog.tscn"))
	_dialog = FILE_DIALOG.instantiate()
	_dialog.title = "Select a GDShader File"
	_dialog.filters = ["*.gdshader", "*.gdshaderinc"]
	_dialog.file_selected.connect(_open_toolbox)
	add_child(_dialog)
	
	
func _open_toolbox(src : String) -> void:
	if is_instance_valid(_dialog):
		_dialog.queue_free.call_deferred()
		_dialog = null
	
	if is_instance_valid(_tbox):
		_tbox.queue_free()
		_tbox = null
		
	var path : String = get_script().resource_path
	var CODE : PackedScene = ResourceLoader.load(path.get_base_dir().path_join("code.tscn"))
	var window : Window = CODE.instantiate()
	if is_instance_valid(window):
		_tbox = window
		
		add_child(window)
		
		window.show()
		window.move_to_center()
		
		if !window.has_focus():
			window.grab_focus()
			
		window.set_src.call_deferred(src, true)
	
func disable_export_check(disable : bool) -> void:
	if disable:
		process_export_check.visible = false
		process_export_check.button_pressed = false
	else:
		process_export_check.visible = true
	
func _enter_tree() -> void:
	add_to_group(&"GDShedor")
	
func save_settings() -> void:
	_save = true
	reset()
	
func _exit_tree() -> void:
	remove_from_group(&"GDShedor")
	_save_settings()
	
func _save_settings() -> void:
	var cfg : ConfigFile = ConfigFile.new()
	var pth : String = get_script().resource_path.get_base_dir()
	
	pth = pth.path_join("user_config.cfg")
	
	cfg.load(pth)
	
	for x : Node in [
		process_export_check,
		obfuscate_symbols_check,
		strip_commentary_check,
		strip_lines_check,
		remove_unused_uniforms_check,
		remove_unused_functions_check,
		replace_constants_check,
		target_obfuscation_length,
		header_text_edit,
		footer_text_Edit,
		prefix_line,
		custom_names_path,
		custom_locked_path,
		select_file_uniforms ,
		select_file_locked ,
		no_test_check_button ,
		no_preserve_shaderinc,
		enable_custom_symbol_names,
		enable_custom_locked_names,
		embed_shadering,
		custom_seed
	]:
		if x is Button:
			cfg.set_value(SETTING, x.name, x.button_pressed)
		elif x is LineEdit:
			cfg.set_value(SETTING, x.name, x.text)
		elif x is TextEdit:
			cfg.set_value(SETTING, x.name, x.text)
		elif x is SpinBox:
			cfg.set_value(SETTING, x.name, x.value)
	
	cfg.save(pth)
	
func reset(d : float = 0.0) -> void:
	_dlt = d
	set_process(true)
	
func _process(delta: float) -> void:
	_dlt += delta
	if _dlt < RESET:
		return
		
	set_process(false)
	
	if _save:
		_save = false
		_save_settings()
	
func _setup() -> void:
	var arr : PackedStringArray = [
		"process_export_check",
		"obfuscate_symbols_check",
		"strip_commentary_check",
		"strip_lines_check",
		"remove_unused_uniforms_check",
		"remove_unused_functions_check",
		"replace_constants_check",
		"target_obfuscation_length",
		"header_text_edit",
		"footer_text_Edit",
		"prefix_line",
		"custom_names_path",
		"custom_locked_path",
		"select_file_uniforms" ,
		"select_file_locked" ,
		"no_test_check_button" ,
		"no_preserve_shaderinc",
		"enable_custom_symbol_names",
		"enable_custom_locked_names",
		"embed_shadering",
		"custom_seed"
		]
	
	for n : Node in get_tree().get_nodes_in_group(&"GDShedor"):
		if n == self:
			continue
		
		for y : String in arr:
			var x : Variant = get(y)
			if x is Button:
				x.button_pressed = n.get(y).get(&"button_pressed")
			elif x is LineEdit:
				x.text = n.get(y).get(&"text")
			elif x is TextEdit:
				x.text = n.get(y).get(&"text")
			elif x is SpinBox:
				x.value = n.get(y).get(&"value")
		
		return
	
	var pth : String = get_script().resource_path.get_base_dir()
	pth = pth.path_join("user_config.cfg")
	
	if !FileAccess.file_exists(pth):
		return
		
	var cfg : ConfigFile = ConfigFile.new()	
	if cfg.load(pth) == OK:
		for s : String in arr:
			var x : Variant = get(s)
			if !(x is Node):
				continue
			elif !cfg.has_section_key(SETTING, x.name):
				continue
				
			if x is Button:
				x.button_pressed = cfg.get_value(SETTING, x.name, false)
			elif x is LineEdit:
				x.text = cfg.get_value(SETTING, x.name, "")
			elif x is TextEdit:
				x.text = cfg.get_value(SETTING, x.name, "")
			elif x is SpinBox:
				x.value = cfg.get_value(SETTING, x.name, 0)
