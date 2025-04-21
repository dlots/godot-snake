class_name SnakeMovedEvent
extends RefCounted

var move: Vector2i
var prev_rotation_degrees: float
var prev_flip_h: bool
var bent: bool
var bent_rotation_degrees: float

func _init(_move, _prev_rotation_degrees, _prev_flip_h, _bent, _bent_rotation):
	move = _move
	prev_rotation_degrees = _prev_rotation_degrees
	prev_flip_h = _prev_flip_h
	bent = _bent
	bent_rotation_degrees = _bent_rotation
