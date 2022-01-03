extends Node2D

var grid_pos
var tname = "Wires"
var placed_turn
var movable = true
var use_power = true
var powered = false


func power_socket(direct):
	if get_parent().get_parent().get_node("Pressure Plates").get_cellv(grid_pos + direct) == 1:
		get_parent().get_parent().get_node("Pressure Plates").set_cellv(grid_pos + direct, 2)


func transmit_each_turn():
	match floor(rotation):
		0.0, 3.0:
			if powered:
				get_parent().power(grid_pos + Vector2.LEFT)
				get_parent().power(grid_pos + Vector2.RIGHT)
				power_socket(Vector2.LEFT)
				power_socket(Vector2.RIGHT)
		1.0, 4.0:
			if powered:
				get_parent().power(grid_pos + Vector2.UP)
				get_parent().power(grid_pos + Vector2.DOWN)
				power_socket(Vector2.UP)
				power_socket(Vector2.DOWN)
