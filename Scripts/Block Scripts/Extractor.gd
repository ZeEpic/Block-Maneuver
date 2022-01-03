extends Node2D

var grid_pos
var tname = "Extractor"
var placed_turn
var movable = true
var use_power = true
var powered = false


func extract(direct):
	if get_tree().get_root().get_node("Game/Terrian").get_cellv(grid_pos - direct) == 4 and not get_parent().get_type(grid_pos - direct) in [null, "Tunnel"]: #and get_parent().get_type():
		get_parent().move(grid_pos - direct, grid_pos + direct)


func first_each_turn():
	if powered:
		match floor(rotation):
				0.0: extract(Vector2.RIGHT)
				1.0: extract(Vector2.DOWN)
				3.0: extract(Vector2.LEFT)
				4.0: extract(Vector2.UP)
