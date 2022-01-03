extends Node2D

var blocks = {} # stores the block names and scene data

var finished_end = true # most of the time it's true except during the end sequence
var all_block_outline = preload("res://Assets/Images/All Block Outline.svg")

func _ready():
	var dir = Directory.new()
	if dir.open("res://Scenes/Block Scenes") == OK: # looking at all the block scene files
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var fixed_name = file_name.trim_suffix(".tscn").replace(".","") # gets the real name of the block
			if fixed_name != "":
				blocks[fixed_name] = load("res://Scenes/Block Scenes/"+fixed_name+".tscn") # adds the block found to the variable
			file_name = dir.get_next() # goes to the next one
		dir.list_dir_end()


func _process(_delta):
	get_parent().get_node("UI/Label").text = str(go_next) # for DEBUG only
	for i in get_children(): # looks at all blocks
		if i.get_children()[-1].visible and get_parent().get_node("Outline").position == i.position: # is the block selected?
			i.get_children()[-1].hide() # hide the outline
		elif not i.get_children()[-1].visible and get_parent().get_node("Outline").position != i.position or not get_parent().get_node("Outline").visible:
			i.get_children()[-1].show() # otherwise show it
	if not finished_end and end_index == len(things):
		end_end() # once it has finished the sequence it will wrap up with end end
	for i in get_children():
		i.position = i.grid_pos * 32 # always updating the position so all I have to use is the grid pos
	if go_next and not finished_end and gt.timer_done: # setting up the next animation or sound once the conditions are ready
		gt.timer_done = false # reset timer
		print(things)
		for i in get_children():
			if things[end_index][0] == i: # if this block is the one that is next in line
				match things[end_index][1]: # find out what type of thing it is going to do and run that function
					0:
						i.get_node("Using").hide() # reset using icon
						var used = i.used() # runs whatever the block wants to do when being used
						if used != null: # updates whatever resource the block has used
							if "coins" in used.keys():
								get_parent().coins += used["coins"]
							if "stone" in used.keys():
								get_parent().stone += used["stone"]
							if "wood" in used.keys():
								get_parent().wood += used["wood"]
							if "copper" in used.keys():
								get_parent().copper += used["copper"]
							if "dirt" in used.keys():
								get_parent().dirt += used["dirt"]
					# all of other kinds of things that can happen in the turn
					1: i.turn_placed()
					2: i.power_each_turn()
					3: i.transmit_each_turn()
					4: i.first_each_turn()
					5: i.each_turn()
		go_next = false
		end_index += 1 # go to the next block in line


func rotate_tile(spot):
	for i in get_children():
		if i.grid_pos == spot: # is the block at the location?
			if i.rotation_degrees == 270: # fixes the rotation being more than or equal to 360 degrees so my code works
				i.rotation_degrees = 0
			else:
				i.rotation_degrees += 90 # otherwise actually rotate it
			return


func move(spot, where):
	for i in get_children():
		if i.grid_pos == spot: # is the block at the location?
			if get_parent().get_node("Terrian").get_cellv(where) != -1:
				#get_parent().get_node("BlockMove").interpolate_property(i, "grid_pos", i.grid_pos, where, i.grid_pos.distance_to(where)/3, Tween.TRANS_LINEAR, Tween.EASE_IN)
				#get_parent().get_node("BlockMove").start()
				i.grid_pos = where # just move it to the spot instantly
				return


func power(spot):
	for i in get_children():
		if i.grid_pos == spot and i.use_power: # is the block at the location and does it actually use power?
			i.powered = true # so power it and make sure it only powers the top block
			return


func get_powered(spot):
	for i in get_children():
		if i.grid_pos == spot and i.use_power: # if it's power and in the right spot
			return true # then yep!

func get_type(spot):
	for i in get_children():
		if i.grid_pos == spot: # simply returns the name of the block that is in this location
			return i.tname


func delete(spot):
	for i in get_children():
		if i.grid_pos == spot: # if the block is in that spot
			i.queue_free() # it frees it from the tree
			return # and makes sure no others are deleted


func get_movable(spot):
	for i in get_children():
		if i.grid_pos == spot: # if it can moved then yep
			return i.movable


func get_turn(spot):
	for i in get_children():
		if i.grid_pos == spot: # if this is the right block then it will return the turn it was placed
			return i.placed_turn


func make_block(spot, which, interact=true): # creates blocks in the spot
	var newb = blocks[which].instance() # find the scene data that was loaded at the start by indexing the dictionary
	newb.grid_pos = spot
	if interact:
		newb.placed_turn = get_parent().turn # if you can interact with it it will get a turn placed so it can be rotated and such
	var outline = Sprite.new() # makes a outline sprite and sets the right properties for that
	outline.texture = all_block_outline
	outline.scale = Vector2(0.064, 0.064)
	newb.add_child(outline) # adds all the instanced things
	add_child(newb)


func set_using(spot):
	for i in get_children():
		if i.grid_pos == spot and i.find_node("Using") != null: # has a using icon and is in the right spo
			i.get_node("Using").visible = not i.get_node("Using").visible # toggles the icon
			if i.get_node("Using").visible: # returns the outcome
				return true
			else:
				return false

var things = [] # some variables for the end sequence
var end_index = 0
var go_next = true

func end_turn():
	print("endin")
	finished_end = false
	for i in get_children():
		if i.find_node("Using") != null:
			if i.get_node("Using").visible:
				things.append([i, 0]) # adds it as using if the icon is there and enabled
		if i.placed_turn == get_parent().turn and i.has_method("turn_placed"): # if this is the right turn and it wants to do something on the turn placed then
			things.append([i, 1])
	
	# for the rest of them it's just adding it to the list if it is going to do something that turn
	for i in get_children():
		if i.has_method("power_each_turn"):
			things.append([i, 2])
	
	
	for i in get_children():
		if i.has_method("transmit_each_turn"):
			things.append([i, 3])
	
	
	for i in get_children():
		if i.has_method("first_each_turn"):
			things.append([i, 4])
		
	for i in get_children():
		if i.has_method("each_turn"):
			things.append([i, 5])

func end_end():
	for i in get_children():
		if i.use_power: # resets all the power
			i.powered = false
		if get_parent().get_node("Terrian").get_cellv(i.grid_pos) == 4: # if theres a block ontop of a hole it makes it immovable and makes it a bit smaller
			i.movable = false
			i.scale = Vector2.ONE*0.75
		elif i.scale == Vector2.ONE*0.75: # but if it was in a hole and it isn't anymore, it makes it full size and makes it movable again
			i.scale = Vector2.ONE
			if i.tname != "Mine":
				i.movable = true
		if i.has_method("end"):
			i.end()
	finished_end = true # resets all the ending variables
	go_next = false
	things = []
	end_index = 0


func _on_BlockMove_tween_completed(object, key): # *Not using right now*
	for i in get_children():
		if i.has_method("done"):
			print(i.name)
			print(object.grid_pos, object.tname)
			i.done()
