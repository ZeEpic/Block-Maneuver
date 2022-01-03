extends Node2D

var grid_pos
var tname = "Wheel"
var placed_turn
var movable = true
var use_power = true
var powered = false


func turn(direct):
	if get_parent().get_movable(grid_pos + direct):
		get_parent().rotate_tile(grid_pos + direct)
		$AudioStreamPlayer2D.play()
	else:
		get_parent().go_next = true


func first_each_turn():
	if powered:
		match floor(rotation):
				0.0: turn(Vector2.RIGHT)
				1.0: turn(Vector2.DOWN)
				3.0: turn(Vector2.LEFT)
				4.0: turn(Vector2.UP)
	else:
		get_parent().go_next = true


func _on_AudioStreamPlayer2D_finished():
	get_parent().go_next = true
