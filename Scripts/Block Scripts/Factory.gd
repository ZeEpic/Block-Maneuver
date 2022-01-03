extends Node2D

var grid_pos
var tname = "Factory"
var placed_turn
var movable = true
var use_power = false

func push(direct):
	var dist = 1
	while get_parent().get_parent().get_node("Terrian").get_cellv(grid_pos + direct*dist) != -1:
		if get_parent().get_type(grid_pos + direct*dist) == null:
			while dist > 1:
				dist -= 1
				get_parent().move(grid_pos + direct*dist, grid_pos + direct*dist + direct)
				print(dist)
			get_parent().make_block(grid_pos + direct*dist, 'Stone')
			return true
		elif not get_parent().get_movable(grid_pos + direct*dist):
			break
		dist += 1
	return false


func used():
	print("using factory")
	if get_parent().get_parent().stone > 0:
		match floor(rotation):
			0.0: if push(Vector2.RIGHT):
					$AudioStreamPlayer2D.play()
					return {"stone": -1}
			1.0: if push(Vector2.DOWN):
					$AudioStreamPlayer2D.play()
					return {"stone": -1}
			3.0: if push(Vector2.LEFT):
					$AudioStreamPlayer2D.play()
					return {"stone": -1}
			4.0: if push(Vector2.UP):
					$AudioStreamPlayer2D.play()
					return {"stone": -1}


func _on_AudioStreamPlayer2D_finished():
	get_parent().go_next = true
	print("audio")
