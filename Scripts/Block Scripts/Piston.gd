extends Node2D

var grid_pos
var tname = "Piston"
var placed_turn
var movable = true
var use_power = false

func end():
	$Tween.interpolate_property($Arm, "position", Vector2(11.9, 0), Vector2(5.2, 0), 1)
	$Tween.start()


func push(direct):
	$AudioStreamPlayer2D.play()
	var dist = 1
	while get_parent().get_parent().get_node("Terrian").get_cellv(grid_pos + direct*dist) != -1:
		if get_parent().get_type(grid_pos + direct*dist) == null:
			while dist > 1:
				dist -= 1
				get_parent().move(grid_pos + direct*dist, grid_pos + direct*dist + direct)
			return true
		elif not get_parent().get_movable(grid_pos + direct*dist):
			break
		dist += 1
	return false


func each_turn():
	match floor(rotation):
			0.0: push(Vector2.RIGHT)
			1.0: push(Vector2.DOWN)
			3.0: push(Vector2.LEFT)
			4.0: push(Vector2.UP)

func _on_AudioStreamPlayer2D_finished():
	get_parent().go_next = true
