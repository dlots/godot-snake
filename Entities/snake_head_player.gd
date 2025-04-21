extends Area2D

const CELL_SIZE_PX = 32

const CONTROLS = {
	LEFT = &"move_left",
	RIGHT =  &"move_right",
	UP = &"move_up",
	DOWN = &"move_down"
}

const OPPOSITE = {
	CONTROLS.LEFT: CONTROLS.RIGHT,
	CONTROLS.RIGHT: CONTROLS.LEFT,
	CONTROLS.UP: CONTROLS.DOWN,
	CONTROLS.DOWN: CONTROLS.UP
}

const BENT_ROTATIONS = {
	CONTROLS.DOWN + CONTROLS.RIGHT: 0,
	CONTROLS.LEFT + CONTROLS.UP: 0,
	CONTROLS.UP + CONTROLS.RIGHT: 90,
	CONTROLS.LEFT + CONTROLS.DOWN: 90,
	CONTROLS.UP + CONTROLS.LEFT: 180,
	CONTROLS.RIGHT + CONTROLS.DOWN: 180,
	CONTROLS.DOWN + CONTROLS.LEFT: 270,
	CONTROLS.RIGHT + CONTROLS.UP: 270
}

# temp constants, should be settings
const CELL_TRAVERSE_SPEED_SEC = 0.1

var accumulated_time: float = 0
var pending_action: StringName = CONTROLS.LEFT
var current_action: StringName = CONTROLS.LEFT


signal snake_moved(event: SnakeMovedEvent)


func get_rotation_with_flip(degrees: float) -> float:
	return degrees * (-1 if $AnimatedSprite2D.flip_h else 1)


func _process(delta: float) -> void:
	# read input
	for key in CONTROLS:
		var action: StringName = CONTROLS[key]
		if Input.is_action_pressed(action) and action != OPPOSITE[current_action]:
			pending_action = action
			break
	
	# snake traverses a cell per defined time period
	accumulated_time += delta
	if accumulated_time < CELL_TRAVERSE_SPEED_SEC:
		return
		
		
	var bent: bool = current_action != pending_action
	var bent_rotation_degrees: float = 0
	if bent:
		bent_rotation_degrees = BENT_ROTATIONS[current_action + pending_action]
	
	# save current direction to ignore opposite inputs
	current_action = pending_action
	accumulated_time -= CELL_TRAVERSE_SPEED_SEC

	# determine movement vector and sprite rotation
	var move: Vector2i = Vector2i(0, 0)
	var prev_rotation_degrees: float = self.rotation_degrees
	var prev_flip_h: bool = $AnimatedSprite2D.flip_h
	self.rotation_degrees = 0
	match pending_action:
		CONTROLS.LEFT:
			$AnimatedSprite2D.flip_h = false
			move = Vector2.LEFT
		CONTROLS.RIGHT:
			$AnimatedSprite2D.flip_h = true
			move = Vector2.RIGHT
		CONTROLS.UP:
			self.rotation_degrees = get_rotation_with_flip(90)
			move = Vector2.UP
		CONTROLS.DOWN:
			self.rotation_degrees = get_rotation_with_flip(270)
			move = Vector2.DOWN
		_:
			pass
	
	# notify the game
	snake_moved.emit(SnakeMovedEvent.new(move, prev_rotation_degrees, prev_flip_h, bent, bent_rotation_degrees))
