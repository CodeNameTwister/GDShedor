@tool
extends CodeEdit
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# GDShedor
# https://github.com/CodeNameTwister/gdshedor/LICENSE
#
# author:	CodeNameTwister
# license:	Copyrights © 2026 by Twister. All rights reserved
# contact:	https://github.com/CodeNameTwister/gdshedor/issues
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const MIN_FONT_SIZE : int = 8
const MAX_FONT_SIZE : int = 48

@export var source_code_search : Panel 

func _ready() -> void:
	text = ""

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.is_command_or_control_pressed():
		var current_size : int = get_theme_font_size("font_size")
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			add_theme_font_size_override("font_size", clamp(current_size + 1, MIN_FONT_SIZE, MAX_FONT_SIZE))
			accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			add_theme_font_size_override("font_size", clamp(current_size - 1, MIN_FONT_SIZE, MAX_FONT_SIZE))
			accept_event()

func _input(event : InputEvent) -> void:
	
	if not event is InputEventKey or !event.pressed or event.echo:
		return
	
	if event.keycode == KEY_ESCAPE:
		if source_code_search.visible and (has_focus() or source_code_search.is_search_focused()):
			source_code_search.close()
		else:
			_on_close_requested()
	elif event.keycode == KEY_F and event.ctrl_pressed:
		if has_focus():
			source_code_search.open()
		#get_viewport().set_input_as_handled()

func _on_close_requested() -> void:
	source_code_search.hide()
