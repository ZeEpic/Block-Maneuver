extends Node2D

var grid_pos
var tname = "Generator"
var placed_turn
var movable = true
var use_power = false


func power_sockets():
	for i in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		if get_parent().get_parent().get_node("Pressure Plates").get_cellv(grid_pos + i) == 1:
			get_parent().get_parent().get_node("Pressure Plates").set_cellv(grid_pos + i, 2)
	$AudioStreamPlayer2D.play()


func power_each_turn():
	if get_parent().get_type(grid_pos + Vector2.RIGHT) != null and get_parent().get_powered(grid_pos + Vector2.RIGHT):
		get_parent().power(grid_pos + Vector2.RIGHT)
	if get_parent().get_type(grid_pos + Vector2.LEFT) != null and get_parent().get_powered(grid_pos + Vector2.LEFT):
		get_parent().power(grid_pos + Vector2.LEFT)
	if get_parent().get_type(grid_pos + Vector2.UP) != null and get_parent().get_powered(grid_pos + Vector2.UP):
		get_parent().power(grid_pos + Vector2.UP)
	if get_parent().get_type(grid_pos + Vector2.DOWN) != null and get_parent().get_powered(grid_pos + Vector2.DOWN):
		get_parent().power(grid_pos + Vector2.DOWN)
	power_sockets()


func _on_AudioStreamPlayer2D_finished():
	get_parent().go_next = true
