extends Node2D

var selected = 1
var top_sel = 0
var lvl_info = {
	"terrian": [],
	"top_terrian": [],
	"coins": 0,
	"stone": 0,
	"wood": 0,
	"copper": 0,
	"dirt": 0
}

func highlight(which):
	for i in range(0,5):
		if i == which:
			$UI/Options/Panel/HBox.get_child(i).color = Color(0.91, 0.62, 0.62)
		else:
			$UI/Options/Panel/HBox.get_child(i).color = Color(0.75, 0.75, 0.75)


func get_grid():
	var inmap_pos = get_global_mouse_position()-Vector2(416, 192)
	return Vector2(round((inmap_pos.x-16)/32)+13, round((inmap_pos.y-16)/32)+6)


func _process(_delta):
	lvl_info["stone"] = $UI/Menu/HBox/Stone.text
	lvl_info["wood"] = $UI/Menu/HBox/Wood.text
	lvl_info["copper"] = $UI/Menu/HBox/Copper.text
	lvl_info["dirt"] = $UI/Menu/HBox/Dirt.text
	lvl_info["coins"] = $UI/Menu/HBox/Coins.text

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == 1:
			var spot = get_grid()
			if spot.x in range(13, 19) and spot.y in range(6, 12):
				$Terrian.set_cellv(spot, selected)
		elif event.button_index == 3:
			var spot = get_grid()
			if spot.x in range(13, 19) and spot.y in range(6, 12):
				if $"Pressure Plates".get_cellv(spot):
					$"Pressure Plates".set_cellv(spot, top_sel)
				else:
					$"Pressure Plates".set_cellv(spot, -1)
		if event.button_index == 4 and $Camera2D.zoom.x > 0.2:
			$Camera2D.zoom -= Vector2.ONE * 0.1
		elif event.button_index == 5 and $Camera2D.zoom.x < 0.7:
			$Camera2D.zoom += Vector2.ONE * 0.1
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_1:
				selected = 1
				highlight(0)
				top_sel = 0
			KEY_2:
				selected = 0
				highlight(1)
				top_sel = 1
			KEY_3:
				selected = 2
				highlight(2)
			KEY_4:
				selected = 3
				highlight(3)
			KEY_QUOTELEFT:
				selected = 4
				highlight(4)


func _on_Save_pressed():
	lvl_info["terrian"] = []
	for y in range(6,12):
		for x in range(13,19):
			lvl_info["terrian"].append($Terrian.get_cell(x,y))
			lvl_info["top_terrian"].append([$"Pressure Plates".get_cell(x,y), x, y])
	var file = File.new()
	if file.file_exists("res://Levels/"+$UI/Menu/HBox/LineEdit.text+".json"):
		var dir = Directory.new().remove("res://Levels/"+$UI/Menu/HBox/LineEdit.text+".json")
	file.open("res://Levels/"+$UI/Menu/HBox/LineEdit.text+".json", File.WRITE)
	file.store_string(JSON.print(lvl_info))
	file.close()
	



func _on_Back_pressed():
	var _a = get_tree().change_scene("res://Scenes/Level Select.tscn")


func _on_Load_pressed():
	var file = File.new()
	var content = {}
	if file.file_exists("res://Levels/"+$UI/Menu/HBox/LineEdit.text+".json"):
		file.open("res://Levels/"+$UI/Menu/HBox/LineEdit.text+".json", File.READ)
		content = JSON.parse(file.get_as_text()).result
		file.close()
	elif $UI/Menu/HBox/LineEdit.text == ts.lvl_name:
		content = JSON.parse(ts.lvl_save).result
	else:
		return

	var x = 13
	var y = 6
	for i in content["terrian"]:
		if x == 19:
			y += 1
			x = 13
		$Terrian.set_cell(x, y, i)
		x += 1
	for i in content["top_terrian"]:
		$"Pressure Plates".set_cell(i[1], i[2], i[0])
		x += 1
	$UI/Menu/HBox/Coins.text = content["coins"]
	$UI/Menu/HBox/Stone.text = content["stone"]
	$UI/Menu/HBox/Wood.text = content["wood"]
	$UI/Menu/HBox/Copper.text = content["copper"]
	$UI/Menu/HBox/Dirt.text = content["dirt"]


func _on_TempSave_pressed():
	lvl_info["terrian"] = []
	for y in range(6,12):
		for x in range(13,19):
			lvl_info["terrian"].append($Terrian.get_cell(x,y))
			lvl_info["top_terrian"].append([$"Pressure Plates".get_cell(x,y), x, y])
	ts.lvl_name = $UI/Menu/HBox/LineEdit.text
	ts.lvl_save = JSON.print(lvl_info)
