extends Node2D

const ROOM_SCENE = preload("res://scenes/Room.tscn")
const ROOM_SIZE := Vector2(256, 192)

func _ready():
	var starting_room = get_node("Room")
	check_room_exits(starting_room)
	
func spawn_room(room_position: Vector2):
	var new_room = ROOM_SCENE.instantiate()

	add_child(new_room)
	new_room.position = room_position
	
func check_room_exits(room):
	if room.north_exit:
		spawn_north_room(room)
		
	if room.south_exit:
		spawn_south_room(room)
		
	if room.east_exit:
		spawn_east_room(room)
		
	if room.west_exit:
		spawn_west_room(room)
		
func spawn_north_room(room):
		spawn_room(
		room.position + Vector2(0, -ROOM_SIZE.y)
	)

func spawn_south_room(room):
		spawn_room(
			room.position + Vector2(0, ROOM_SIZE.y)
		)
		
func spawn_east_room(room):
		spawn_room(
			room.position + Vector2(ROOM_SIZE.x, 0)
		)

func spawn_west_room(room):
		spawn_room(
			room.position + Vector2(-ROOM_SIZE.x, 0)
		)
