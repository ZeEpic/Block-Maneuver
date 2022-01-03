extends Node2D

var grid_pos
var tname = "Ramp"
var placed_turn
var movable = true
var use_power = false


func each_turn():
	match floor(rotation):
		0.0:
			if get_parent().get_type(grid_pos + Vector2.RIGHT * 2) == null and get_parent().get_type(grid_pos + Vector2.LEFT) != null and get_parent().get_movable(grid_pos + Vector2.LEFT):
				get_parent().move(grid_pos + Vector2.LEFT, grid_pos + Vector2.RIGHT * 2)
			else:
				get_parent().go_next = true
		3.0:
			if get_parent().get_type(grid_pos + Vector2.LEFT * 2) == null and get_parent().get_type(grid_pos + Vector2.RIGHT) != null and get_parent().get_movable(grid_pos + Vector2.RIGHT):
				get_parent().move(grid_pos + Vector2.RIGHT, grid_pos + Vector2.LEFT * 2)
			else:
				get_parent().go_next = true
		1.0:
			if get_parent().get_type(grid_pos + Vector2.UP * 2) == null and get_parent().get_type(grid_pos + Vector2.DOWN) != null and get_parent().get_movable(grid_pos + Vector2.DOWN):
				get_parent().move(grid_pos + Vector2.DOWN, grid_pos + Vector2.UP * 2)
			else:
				get_parent().go_next = true
		4.0:
			if get_parent().get_type(grid_pos + Vector2.DOWN * 2) == null and get_parent().get_type(grid_pos + Vector2.UP) != null and get_parent().get_movable(grid_pos + Vector2.UP):
				get_parent().move(grid_pos + Vector2.UP, grid_pos + Vector2.DOWN * 2)
			else:
				get_parent().go_next = true


func done():
	get_parent().go_next = true
	print("wow")
