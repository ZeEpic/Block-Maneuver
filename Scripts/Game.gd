extends Node2D

# defines important variables for the resources and turn
var stone = 0
var wood = 0
var copper = 0
var dirt = 0
var coins = 0

var turn = 1

var blocks = {
	"Mine": {
		'tile': 11,
		'type': null,
		'uses': {},
		'cpu': {
			'Coin': 1
		},
		'desc': "When used, it excanges one coin for one of the resource it is placed on, and depeates that tile of it's resources. It cannot be moved."
	},
	"Factory": {
		'tile': 0,
		'type': "Block_Movers",
		'uses': {
			'Stone': 1,
			'Wood': 2
		},
		'cpu': {
			'Stone': 1
		},
		'desc': "When used, the factory requires one stone to create a stone block and pushes all blocks infront of that."
	},
	"Piston": {
		'tile': 1,
		'type': "Block_Movers",
		'uses': {
			'Stone': 1,
			'Copper': 1
		},
		'cpu': null,
		'desc': "The piston simply pushs all blocks infront of it each turn if possible."
	},
	"Wheel": {
		'tile': 2,
		'type': "Block_Movers",
		'uses': {
			'Stone': 2
		},
		'cpu': null,
		'desc': "When powered, the wheel turns the block infront of it 90 degrees clockwise."
	},
	"Tunnel": {
		'tile': 3,
		'type': "Pathways",
		'uses': {
			'Stone': 1,
			'Dirt': 1
		},
		'cpu': null,
		'desc': "Each turn, it moves blocks in front behind it, and vise versa if possible. It can only be placed in holes."
	},
	"Bridge": {
		'tile': 4,
		'type': "Pathways",
		'uses': {
			'Stone': 1,
			'Dirt': 2
		},
		'cpu': null,
		'desc': "Each turn, it moves blocks in front behind it, and vise versa if possible. It can be placed on top of another block."
	},
	"Ramp": {
		'tile': 5,
		'type': "Pathways",
		'uses': {
			'Stone': 1
		},
		'cpu': null,
		'desc': "Each turn, it moves blocks behind it 2 spaces forwards."
	},
	"Wires": {
		'tile': 6,
		'type': "Electricity",
		'uses': {
			'Copper': 1,
		},
		'cpu': null,
		'desc': "Wires simply transmit power from 1 direction to another."
	},
	"Pulser": {
		'tile': 7,
		'type': "Electricity",
		'uses': {
			'Copper': 2
		},
		'cpu': null,
		'desc': "It generates a pulse of power in all directions the turn it is placed."
	},
	"Generator": {
		'tile': 8,
		'type': "Electricity",
		'uses': {
			'Copper': 3
		},
		'cpu': null,
		'desc': "It gnerates power each turn in all directions."
	},
	"Car": {
		'tile': 9,
		'type': "Advanced",
		'uses': {
			'Stone': 2,
			'Wood': 2,
			'Copper': 2
		},
		'cpu': {
			'Coin': 1
		},
		'desc': "When used, it costs one coin to transport the block in front of it to wherever you click."
	},
	"Extractor": {
		'tile': 10,
		'type': "Advanced",
		'uses': {
			'Stone': 3
		},
		'cpu': null,
		'desc': "If it is next to a hole, it will take the block in the hole and spit it out in the direction it's looking when powered.'"
	}
}

var blockinfo = preload("res://Scenes/Block Info.tscn") # the info box that pops up before you place a block

var doing_end = false # if it's doing the end sequence


func _ready(): # Start
	for i in $UI/Blocks/Panel/HBoxContainer.get_children():
		if i.get_child_count() > 0:
			for j in i.get_node("Panel/VBoxContainer").get_children():
				j.text = j.name # sets names for each block's button based on their names
	var content
	var file = File.new()
	if file.file_exists("res://Levels/"+lm.lvl): # does the json file exist?
		file.open("res://Levels/"+lm.lvl, File.READ)
		content = JSON.parse(file.get_as_text()).result # loads json level info
		file.close()
	elif lm.lvl == ts.lvl_name: # maybe it's a temp save?
		content = JSON.parse(ts.lvl_save).result # load level info from temp save variable instead
	else:
		return # return so it doesn't cause errors if it can't find a json

	var x = 13
	var y = 6
	for i in content["terrian"]:
		if x == 19:
			y += 1
			x = 13
		$Terrian.set_cell(x, y, i) # fill in the terrian tilemap with the data from the json
		x += 1
	for i in content["top_terrian"]:
		$"Pressure Plates".set_cell(i[1], i[2], i[0]) # populate the top overlay from the json
		x += 1
	
	# set the variables for resources based on the json
	coins = int(content["coins"])
	stone = int(content["stone"])
	wood = int(content["wood"])
	copper = int(content["copper"])
	dirt = int(content["dirt"])
	if lm.lvl == null: # if it's from the file, set the level name to that one
		$"UI/Control Panel/Panel/Lvl Name/Label".text = ts.lvl_name.trim_suffix(".json")
	else: # otherwise set it to the level name from the temp save
		$"UI/Control Panel/Panel/Lvl Name/Label".text = lm.lvl.trim_suffix(".json")


func _process(delta): # Every frame
	# sets the labels for each resource to their respective variables
	$UI/Resources/Panel/VBoxContainer/Stone/Label.text = str(stone)
	$UI/Resources/Panel/VBoxContainer/Wood/Label.text = str(wood)
	$UI/Resources/Panel/VBoxContainer/Copper/Label.text = str(copper)
	$UI/Resources/Panel/VBoxContainer/Dirt/Label.text = str(dirt)
	$UI/Resources/Panel/VBoxContainer/Coins/Label.text = str(coins)
	if delta > 0:
		$UI/FPS.text = str(round(1/delta)) # temporary fps display
	if doing_end and $Blocks.finished_end: # ending things and blocks are done animating
		$Outline.hide()
		button_down('Advanced')
		button_down('Block_Movers')
		button_down('Pathways')
		button_down('Electricity')
		turn += 1
		$"UI/Control Panel/Panel/Turn Number/Label".text = str(turn)
		var holes_filled = true
		var pressure = true
		var sockets = true
		for y in range(6,12):
			for x in range(13,19):
				if $Terrian.get_cell(x,y) == 4 and $Blocks.get_type(Vector2(x,y)) == null: #if theres no block on the hole
					holes_filled = false # if the hole isn't filled, all the holes can be assumed as open
				if $"Pressure Plates".get_cell(x,y) == 0 and $Blocks.get_type(Vector2(x,y)) == null: # if theres no block on the plate
					pressure = false # if the plate isn't covered, all the plates can be assumed as open
				if $"Pressure Plates".get_cell(x,y) == 1: # unpowered socket?
					sockets = false # all sockets can be assumed as unpowered
		if pressure and holes_filled and sockets: # everything is covered and powed...
			$"UI/Win Screen".show() # show winscreen and update turn count
			$"UI/Win Screen/Panel/Main Panel/Label".bbcode_text = $"UI/Win Screen/Panel/Main Panel/Label".bbcode_text.replace("0",str(turn))
			if turn == 1: # fixes, "1 turns"
				$"UI/Win Screen/Panel/Main Panel/Label".bbcode_text = $"UI/Win Screen/Panel/Main Panel/Label".bbcode_text.replace("turns","turn")
			$Sounds/Victory.play() # victory sound!
		$Sounds/NextLevel.play() # otherwise go to the next turn because no win
		doing_end = false
	


func _input(event): # Inputs
	if event is InputEventMouseButton and event.pressed: # mouse
		if event.button_index == 2: # right click
			var spot = get_grid()
			if $Outline.visible and $Outline.position == spot*32: # if the click is on the selection
				if $Blocks.get_turn(spot) == turn:
					$Blocks.rotate_tile(spot) # rotate the selected tile and play that sound
					$Sounds/Turn.play()
			else:
				$Outline.hide() # if the click isn't on a block then hide the outline
			if $Blocks.get_type(spot):
				if $Outline.position != spot*32 or not $Outline.visible: # if you click somewhere new then it will play the sound
					$Sounds/Select.play()
				$Outline.show() # puts the outline on the selected block
				$Outline.position = spot*32
		elif event.button_index == 3: # middle click
			var spot = get_grid()
			if $Blocks.set_using(spot):
				$Sounds/Using.play() # if you click on a block, try to toggle it up being used
		if event.button_index == 4 and $Camera2D.zoom.x > 0.2: # scroll up
			$Camera2D.zoom -= Vector2.ONE * 0.1 # zoom in
		elif event.button_index == 5 and $Camera2D.zoom.x < 0.7: # scroll down
			$Camera2D.zoom += Vector2.ONE * 0.1 # zoom out
	if event is InputEventKey and event.pressed: # keyboard
		match event.scancode:
			# numbers 1 though 4 move the button
			KEY_1:
				move_button('Block_Movers')
			KEY_2:
				move_button('Pathways')
			KEY_3:
				move_button('Electricity')
			KEY_4:
				move_button('Advanced')
			KEY_RIGHT:
				end_turn() # you can click the button or press the right arrow key to end the turn
			KEY_BACKSPACE: # deleting the block
				if $Outline.visible and $Blocks.get_turn($Outline.position / 32) == turn: # if theres a selection and it's the turn that block was placed
					var needed = blocks[$Blocks.get_type($Outline.position / 32)]['uses']
					for i in needed.keys():
						match i: # refunds the amount payed for that block
							'Stone': stone += needed[i]
							'Wood': wood += needed[i]
							'Copper': copper += needed[i]
							'Dirt': dirt += needed[i]
					$Blocks.delete($Outline.position / 32) # block deleted
					$Sounds/Trash.play() # plays delete sound
					$Outline.hide() # removes the selection because it no longer excists
			KEY_E: # FOR DEBUG ONLY
				if $Outline.visible:
					$Blocks.move($Outline.position/32, get_grid())
			KEY_SPACE: # other way to set using
				var spot = get_grid()
				if $Blocks.set_using(spot):
					$Sounds/Using.play() # play sound

func end_turn(): # Starting End Sequence
	if not $"UI/Win Screen".visible: # hasn't already won...
		$Blocks.end_turn() # block animtions and sounds
		doing_end = true

func get_grid(): # Find grid position based on mouse position
	var inmap_pos = get_global_mouse_position()-Vector2(416, 192) # mouse position accounting for the position of the tilemap
	return Vector2(round((inmap_pos.x-16)/32)+13, round((inmap_pos.y-16)/32)+6) # returns that but as a grid position


func button_up(which): # Move the block menu buttons up
	$UI/Blocks/Tween.interpolate_property(get_node('UI/Blocks/Panel/HBoxContainer/'+which), 'rect_position',  # finds the on given and is changing the position
		Vector2(get_node('UI/Blocks/Panel/HBoxContainer/'+which).rect_position.x, 0), # finds it's x position because that can change but it always starts at 0 y
		Vector2(get_node('UI/Blocks/Panel/HBoxContainer/'+which).rect_position.x, -143),  # same thing but it will always go to -143 y
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT) # takes 0.15 seconds and is linear
	$UI/Blocks/Tween.start() # you need to use .start() otherwise nothing will happen
	

func button_down(which): # Same as button up but starts at the current position and goes to 0 y
	$UI/Blocks/Tween.interpolate_property(get_node('UI/Blocks/Panel/HBoxContainer/'+which), 'rect_position', 
		get_node('UI/Blocks/Panel/HBoxContainer/'+which).rect_position, 
		Vector2(get_node('UI/Blocks/Panel/HBoxContainer/'+which).rect_position.x, 0), 
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$UI/Blocks/Tween.start()


func move_button(which): # Moves buttons
	if get_node('UI/Blocks/Panel/HBoxContainer/'+which).rect_position.y == 0: # if it isn't open, move the button up and play the sound
		button_up(which)
		$"UI/Blocks/Audio Open".play()
	else: # otherwise move it back down and play a sound
		button_down(which)
		$"UI/Blocks/Audio Close".play()

#All the signals from the block menus
func _on_Advanced_pressed():
	move_button('Advanced')


func _on_Block_Movers_pressed():
	move_button('Block_Movers')


func _on_Pathways_pressed():
	move_button('Pathways')


func _on_Electricity_pressed():
	move_button('Electricity')


func can_place(name): # Can the block be placed?
	var spot = get_grid()
	var uses = blocks[name]['uses']
	var can_make = true
	for i in uses.keys(): # it looks at all the required resources and if any aren't available, it assumes the rest as the same
		if i == 'Stone' and stone < uses[i]:
			can_make = false
		elif i == 'Wood' and wood < uses[i]:
			can_make = false
		elif i == 'Copper' and copper < uses[i]:
			can_make = false
		elif i == 'Dirt' and dirt < uses[i]:
			can_make = false
	if can_make and not $"UI/Win Screen".visible: # If all the resources are available and each condition is met...
		if ((not $Blocks.get_type(spot)) or name == "Bridge" and $Blocks.get_type(spot) != "Bridge") and $"Pressure Plates".get_cellv(spot) != 0 and spot.x in range(13, 19) and spot.y in range(6, 12):
			if $Terrian.get_cellv(spot) == 4 and name == "Tunnel": # tunnels have a special case
				return true
			elif not $Terrian.get_cellv(spot) == 4 and name != "Tunnel": # things that aren't tunnels
				return true
			else: # conditions not met
				return false


func place_block(name): # If it actually can place the block
	var spot = get_grid()
	var uses = blocks[name]['uses']
	for i in uses.keys(): # subtracts all the resources it uses because we know by this point that there is enough to do so
		if i == 'Stone': stone -= uses[i]
		elif i == 'Wood': wood -= uses[i]
		elif i == 'Copper': copper -= uses[i]
		elif i == 'Dirt': dirt -= uses[i]
	$Sounds/PlaceBlock.play() # plays block placing sound
	$Blocks.make_block(spot, name) # uses block manager to make a block


func highlight(which): # Highlight which resources are used
	for i in which:
		get_node("UI/Resources/Panel/VBoxContainer/"+i).color = Color(0.78, 0.2, 0.31) # sets those reources to have a red background
		
func un_highlight(): # Resets all highlights
	for i in $UI/Resources/Panel/VBoxContainer/.get_children(): # looks at each resources counter
		i.color = Color(0.62, 0.62, 0.91) # sets it's color to gray


func show_info(which): # Creates and formats the info box that appears before you place down a block
	var new_info = blockinfo.instance() # make a new info box
	new_info.get_node("Panel/Name/Label").text = which # set the top label to the name of the block
	var file = File.new()
	if file.file_exists("res://Scenes/Block Scenes/"+which+".tscn"): # does the scene for this block name exist?
		file.open("res://Scenes/Block Scenes/"+which+".tscn", File.READ)
		var content = file.get_as_text()
		var regex = RegEx.new()
		regex.compile("Rect2\\( (.*), (.*)") # use regex to find where it has the range within the tscn file
		var result = regex.search(content)
		if result:
			var region = result.get_string().lstrip("Rect2( ").split(", ") # finds the exact numbers and puts them in a list
			new_info.get_node("Panel/Name/Sprite").region_rect = Rect2(Vector2(int(region[0]), int(region[1])), Vector2.ONE * 32) # makes the little preview of the block set to that region
	new_info.get_node("Panel/Info/Label").text = blocks[which]["desc"] # updates the description from the blocks variable
	$UI/Info.add_child(new_info) # finally adds the new box to the UI


func hide_info(): # Hide info box
	$UI/Info.get_child(0).queue_free() # deletes it once the block has been placed


func buttdown(block_name): # When you start to drag the block from the button
	highlight(blocks[block_name]['uses'].keys()) # highlight the required resources, show the info box, and play the button sound
	show_info(block_name)
	$Sounds/ButtPress.play()


func buttup(block_name): # Finished draging the new block
	if can_place(block_name): place_block(block_name) # can it place it? then it does
	un_highlight() # removes highlights and hides the info box
	hide_info()

# All of signals from the block's buttons: is there a better way to do this?
func _on_Factory_button_up():
	buttup('Factory')
func _on_Factory_button_down():
	buttdown('Factory')
func _on_Piston_button_down():
	buttdown('Piston')
func _on_Piston_button_up():
	buttup('Piston')
func _on_Wheel_button_down():
	buttdown('Wheel')
func _on_Wheel_button_up():
	buttup('Wheel')
func _on_Tunnel_button_down():
	buttdown('Tunnel')
func _on_Tunnel_button_up():
	buttup('Tunnel')
func _on_Bridge_button_down():
	buttdown('Bridge')
func _on_Bridge_button_up():
	buttup('Bridge')
func _on_Ramp_button_down():
	buttdown('Ramp')
func _on_Ramp_button_up():
	buttup('Ramp')
func _on_Wires_button_down():
	buttdown('Wires')
func _on_Wires_button_up():
	buttup('Wires')
func _on_Pulser_button_down():
	buttdown('Pulser')
func _on_Pulser_button_up():
	buttup('Pulser')
func _on_Generator_button_down():
	buttdown('Generator')
func _on_Generator_button_up():
	buttup('Generator')
func _on_Car_button_down():
	buttdown('Car')
func _on_Car_button_up():
	buttup('Car')
func _on_Extractor_button_down():
	buttdown('Extractor')
func _on_Extractor_button_up():
	buttup('Extractor')
func _on_Mine_button_up():
	buttup('Mine')
func _on_Mine_button_down(): # Special ones for the mine because it's not in any menu so we play the button press sound
	buttdown('Mine')
	$Sounds/ButtPress.play()

func _on_Next_Turn_pressed(): # Same as pressing right arrow key but makes a sound
	$Sounds/ButtPress.play()
	end_turn()


func _on_Back_pressed(): # Back to the level select
	$Sounds/ButtPress.play() # plays sound and changes the scene
	var _a = get_tree().change_scene("res://Scenes/Level Select.tscn")


func _on_Toggle_Over_toggled(button_pressed): # Makes the pressure plates and sockets visible or not so it's easier to see your blocks
	if $"Pressure Plates".self_modulate == Color.white:
		$"Pressure Plates/Tween".interpolate_property($"Pressure Plates", "self_modulate", Color.white, Color(1,1,1,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT) # Change the alpha so it slowly fades away
	else:
		$"Pressure Plates/Tween".interpolate_property($"Pressure Plates", "self_modulate", Color(1,1,1,0), Color.white, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT) # Change the alpha so it slowly fades back in
	$"Pressure Plates/Tween".start()
	print("what")
