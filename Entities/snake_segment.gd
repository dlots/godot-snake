class_name SnakeSegment
extends Area2D

func init(_position: Vector2, properties: SnakeMovedEvent):
	self.position = _position
	if not properties:
		$AnimatedSprite2D.animation = &"Straight"
		return
	self.rotation_degrees = properties.bent_rotation_degrees if properties.bent else properties.prev_rotation_degrees
	$AnimatedSprite2D.flip_h = not properties.bent and properties.prev_flip_h
	$AnimatedSprite2D.animation = &"Bending" if properties.bent else &"Straight"


func _on_child_exiting_tree(_node: Node) -> void:
	queue_free()
