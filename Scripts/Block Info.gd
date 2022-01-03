extends Control

var yes = preload("res://Assets/Images/yes.png")
var no = preload("res://Assets/Images/no.png")

func _process(_delta):
	if get_tree().get_root().get_node("Game").can_place($Panel/Name/Label.text):
		$Panel/Info/Sprite.texture = yes
	else:
		$Panel/Info/Sprite.texture = no
