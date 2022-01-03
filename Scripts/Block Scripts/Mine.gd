extends Node2D


var grid_pos
var tname = "Mine"
var placed_turn
var movable = false
var use_power = false

func used():
	if get_parent().get_parent().coins > 0:
		var tiles = get_parent().get_parent().get_node("Terrian")
		var tile = tiles.get_cellv(grid_pos)
		if tile <= 3:
			tiles.set_cellv(grid_pos, tile+5)
			match tile:
				0:
					$Wood.play()
					return {"coins": -1, "wood": 1}
				1:
					$Stone.play()
					return {"coins": -1, "stone": 1}
				2:
					$Copper.play()
					return {"coins": -1, "copper": 1}
				3:
					$Dirt.play()
					return {"coins": -1, "dirt": 1}
		else:
			print("ok so its already been used...")
			get_parent().go_next = true
	else:
		get_parent().go_next = true


func _on_Wood_finished():
	get_parent().go_next = true


func _on_Stone_finished():
	get_parent().go_next = true


func _on_Copper_finished():
	get_parent().go_next = true


func _on_Dirt_finished():
	get_parent().go_next = true
