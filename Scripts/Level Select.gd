extends Node2D


var level = preload("res://Scenes/Level.tscn")


func _ready():
	var lvlset = 1
	var dir = Directory.new()
	if dir.open("res://Levels") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var fixed_name = file_name.trim_suffix(".json").replace(".","")
			if fixed_name != "":
				if get_node("UI/Options/VBox/Levelset"+str(lvlset)).get_child_count() == 6:
					lvlset += 1
				var new_but = level.instance()
				new_but.text = fixed_name
				new_but.fname = file_name
				get_node("UI/Options/VBox/Levelset"+str(lvlset)).add_child(new_but)
			file_name = dir.get_next()
		dir.list_dir_end()
	if ts.lvl_save != null:
		var new_but = level.instance()
		new_but.text = ts.lvl_name
		new_but.fname = ts.lvl_name
		get_node("UI/Options/VBox/Levelset"+str(lvlset)).add_child(new_but)


func _input(event):
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_ENTER:
				var _a = get_tree().change_scene("res://Scenes/Level Maker.tscn")


func _on_Level_Maker_pressed():
	var _a = get_tree().change_scene("res://Scenes/Level Maker.tscn")
