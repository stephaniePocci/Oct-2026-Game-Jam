extends Node2D

const ROOM_SIZE := Vector2(256, 192)

@export var north_exit: bool = false
@export var east_exit: bool = false
@export var south_exit: bool = false
@export var west_exit: bool = false


func _draw():
	# Fill
	draw_rect(
		Rect2(-ROOM_SIZE / 2, ROOM_SIZE),
		Color(0.25, 0.23, 0.22),
		true
	)

	# Border
	draw_rect(
		Rect2(-ROOM_SIZE / 2, ROOM_SIZE),
		Color(0.8, 0.75, 0.65),
		false,
		4.0
	)
