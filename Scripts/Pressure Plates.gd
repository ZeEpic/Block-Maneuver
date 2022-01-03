extends TileMap


func end_turn():
	for i in get_used_cells_by_id(2):
		set_cellv(i, 1)
