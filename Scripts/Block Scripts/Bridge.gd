extends Node2D
# some basic variables
var grid_pos
var tname = "Bridge"
var placed_turn
var movable = true
var use_power = false


func each_turn():
	match floor(rotation):
		0.0, 3.0:
			if get_parent().get_type(grid_pos + Vector2.RIGHT) == null and get_parent().get_type(grid_pos + Vector2.LEFT) != null and get_parent().get_movable(grid_pos + Vector2.LEFT):
				get_parent().move(grid_pos + Vector2.LEFT, grid_pos + Vector2.RIGHT)
				$AudioStreamPlayer2D.play()
			elif get_parent().get_type(grid_pos + Vector2.LEFT) == null and get_parent().get_type(grid_pos + Vector2.RIGHT) != null and get_parent().get_movable(grid_pos + Vector2.RIGHT):
				get_parent().move(grid_pos + Vector2.RIGHT, grid_pos + Vector2.LEFT)
				$AudioStreamPlayer2D.play()
			else:
				print(grid_pos)
				get_parent().go_next = true
		1.0, 4.0:
			if get_parent().get_type(grid_pos + Vector2.UP) == null and get_parent().get_type(grid_pos + Vector2.DOWN) != null and get_parent().get_movable(grid_pos + Vector2.DOWN):
				get_parent().move(grid_pos + Vector2.DOWN, grid_pos + Vector2.UP)
				$AudioStreamPlayer2D.play()
			elif get_parent().get_type(grid_pos + Vector2.DOWN) == null and get_parent().get_type(grid_pos + Vector2.UP) != null and get_parent().get_movable(grid_pos + Vector2.UP):
				get_parent().move(grid_pos + Vector2.UP, grid_pos + Vector2.DOWN)
				$AudioStreamPlayer2D.play()
			else:
				get_parent().go_next = true


func _on_AudioStreamPlayer2D_finished():
	get_parent().go_next = true
