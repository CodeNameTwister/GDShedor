@tool
extends Button
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# GDShedor
# https://github.com/CodeNameTwister/gdshedor/LICENSE
#
# author:	CodeNameTwister
# license:	Copyrights © 2026 by Twister. All rights reserved
# contact:	https://github.com/CodeNameTwister/gdshedor/issues
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

func _pressed() -> void:
	if owner.has_method(name):
		owner.call(name, self)
	else:
		push_error("Very sleepy {0}".format([name]))
