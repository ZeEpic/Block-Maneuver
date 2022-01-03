extends Button

var fname

func _on_Level_pressed():
	lm.lvl = fname
	$AudioStreamPlayer.play()
	var _a = get_tree().change_scene("res://Scenes/Game.tscn")
