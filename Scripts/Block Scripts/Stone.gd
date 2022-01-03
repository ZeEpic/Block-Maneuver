extends Node2D

var grid_pos
var tname = "Stone"
var placed_turn
var movable = true
var use_power = false


func turn_placed():
	return false


func used():
	return {}


func each_turn():
	return false
