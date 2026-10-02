extends Node2D

const ROOM_SCENE = preload("res://scenes/Room.tscn")
const ROOM_SIZE := Vector2(256, 192)


func _ready():
	var starting_room = get_node("Room")

	print("Starting room position: ", starting_room.position)
	print("North exit: ", starting_room.north_exit)

	if starting_room.north_exit:
		spawn_room(
			starting_room.position + Vector2(0, -ROOM_SIZE.y)
		)


func spawn_room(room_position: Vector2):
	var new_room = ROOM_SCENE.instantiate()

	add_child(new_room)

	new_room.position = room_position

	print("Created room at: ", new_room.position)
