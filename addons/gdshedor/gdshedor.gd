@tool
extends EShedorPlugin
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# GDShedor
# https://github.com/CodeNameTwister/gdshedor/LICENSE
#
# author:	CodeNameTwister
# license:	Copyrights © 2026 by Twister. All rights reserved
# contact:	https://github.com/CodeNameTwister/gdshedor/issues
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const DOCK = preload("components/scene/dock.tscn")
var _dock : Node = null

func _ready() -> void:
	tree_exiting.connect(_on_exiting)
	
	_dock = DOCK.instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, _dock)


func _on_exiting() -> void:
	if is_instance_valid(_dock):
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null
