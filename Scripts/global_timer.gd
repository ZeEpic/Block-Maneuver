extends Node

var timer_done = false
var start
var time = 0
var wait_time = 1

func _process(delta):
	if not timer_done:
		time += delta
		if time > wait_time:
			time = 0
			timer_done = true
