extends Node2D

# temp: need to somehow dynamically get this
const WALL_TILE_ID = 0

const SEGMENT_SCENE = preload("res://Entities/snake_segment.tscn")
const FOOD_SCENE = preload("res://Entities/food.tscn")

var snake_segments = []
var food
var score = 0


func get_map_position(local_position: Vector2) -> Vector2i:
	return $Field.local_to_map(local_position)
	
	
func get_local_position(map_position: Vector2i) -> Vector2:
	return $Field.map_to_local(map_position)


func get_segment_cells() -> Array:
	return snake_segments.map(
		func (segment): return get_map_position(segment.position)
	)


func get_random_free_tile() -> Vector2:
	var occupied_cells: Array = get_segment_cells()
	occupied_cells.append(get_map_position($SnakeHead.position))
	var free_cells: Array = $Field.get_used_cells().filter(
		func (cell):
			var tile_id = $Field.get_cell_source_id(cell)
			return tile_id != WALL_TILE_ID and cell not in occupied_cells
	)
	
	if free_cells.is_empty():
		win()
		return Vector2.ZERO
	
	var random_cell = free_cells[randi() % free_cells.size()]
	return get_local_position(random_cell)


func _ready():
	food = FOOD_SCENE.instantiate()
	food.position = get_random_free_tile()
	add_child(food)
	spawn_segment(get_local_position(get_map_position($SnakeHead.position) + Vector2i.RIGHT * 2))
	spawn_segment(get_local_position(get_map_position($SnakeHead.position) + Vector2i.RIGHT))
	

func spawn_segment(_position: Vector2, properties: SnakeMovedEvent = null):
	var new_segment: SnakeSegment = SEGMENT_SCENE.instantiate()
	new_segment.init(_position, properties)
	add_child(new_segment)
	snake_segments.push_front(new_segment)


func _on_snake_moved(event: SnakeMovedEvent):
	var old_position: Vector2 = $SnakeHead.position
	var current_cell: Vector2i = $Field.local_to_map($SnakeHead.position)
	var new_map_position: Vector2i = current_cell + event.move
	var hit_wall: bool = $Field.get_cell_source_id(new_map_position) == WALL_TILE_ID
	var hit_self = new_map_position != get_segment_cells().back() and new_map_position in get_segment_cells()
	if hit_wall or hit_self:
		lose()
		return
	$SnakeHead.position = $Field.map_to_local(new_map_position)
	spawn_segment(old_position, event)
	if get_map_position(food.position) == new_map_position:
		food.position = get_random_free_tile()
		score += 1
		$ScoreCounter.text = str(score)
		return
	# if hungry, do not grow
	var old_tail = snake_segments.pop_back()
	remove_child(old_tail)
	
		
func win():
	pass
	
	
func lose():
	pass
