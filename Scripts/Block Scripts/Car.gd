extends Node2D

var grid_pos
var tname = "Car"
var placed_turn
var movable = true
var use_power = false


func used():
	if get_parent().get_parent().coins > 0:
		var spot = get_parent().get_parent().get_grid()
		if get_parent().get_type(spot) == null and Rect2(13, 6, 6, 6).has_point(spot):
			match floor(rotation):
				0.0: get_parent().move(grid_pos + Vector2.RIGHT, spot)
				1.0: get_parent().move(grid_pos + Vector2.LEFT, spot)
				3.0: get_parent().move(grid_pos + Vector2.DOWN, spot)
				4.0: get_parent().move(grid_pos + Vector2.UP, spot)
		$AudioStreamPlayer2D.play()
		return {"coin": -1}


func _on_AudioStreamPlayer2D_finished():
	get_parent().go_next = true
