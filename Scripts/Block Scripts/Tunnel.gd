extends Node2D

var grid_pos
var tname = "Tunnel"
var placed_turn
var movable = true
var use_power = false

func each_turn():
	match floor(rotation):
		0.0, 3.0:
			if get_parent().get_type(grid_pos + Vector2.RIGHT) == null and get_parent().get_type(grid_pos + Vector2.LEFT) != null and get_parent().get_movable(grid_pos + Vector2.LEFT):
				get_parent().move(grid_pos + Vector2.LEFT, grid_pos + Vector2.RIGHT)
			elif get_parent().get_type(grid_pos + Vector2.LEFT) == null and get_parent().get_type(grid_pos + Vector2.RIGHT) != null and get_parent().get_movable(grid_pos + Vector2.RIGHT):
				get_parent().move(grid_pos + Vector2.RIGHT, grid_pos + Vector2.LEFT)
		1.0, 4.0:
			if get_parent().get_type(grid_pos + Vector2.UP) == null and get_parent().get_type(grid_pos + Vector2.DOWN) != null and get_parent().get_movable(grid_pos + Vector2.DOWN):
				get_parent().move(grid_pos + Vector2.DOWN, grid_pos + Vector2.UP)
			elif get_parent().get_type(grid_pos + Vector2.DOWN) == null and get_parent().get_type(grid_pos + Vector2.UP) != null and get_parent().get_movable(grid_pos + Vector2.UP):
				get_parent().move(grid_pos + Vector2.UP, grid_pos + Vector2.DOWN)


func done():
	get_parent().go_next = true
