extends Control


func _process(_delta):
	if get_child_count() == 1:
		get_child(0).rect_position = get_viewport().get_mouse_position()
