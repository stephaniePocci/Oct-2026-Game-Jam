extends Node2D

const ROOM_SCENE = preload("res://scenes/Room.tscn")
const ROOM_SIZE := Vector2(256, 192)
@export var item_definitions: Array[ItemDefinition] = []
var token
var move_tween: Tween
var item_chances_valid := true

func _ready():
	var starting_room = get_node("Room")
	starting_room.side_clicked.connect(_on_room_side_clicked)
	token = get_node("CharacterToken")
	starting_room.room_clicked.connect(_on_room_clicked)
	item_chances_valid = _validate_item_chances()
	_spawn_item(starting_room)

func _validate_item_chances() -> bool:
	var total := 0
	for item in item_definitions:
		if item == null or item.spawn_chance < 0 or item.spawn_chance > 100:
			push_error("Each room item needs a spawn chance between 0% and 100%.")
			return false
		total += item.spawn_chance
	if total > 100:
		push_error("Room item spawn chances must total no more than 100%.")
		return false
	return true

func _spawn_item(room) -> void:
	if not item_chances_valid:
		return
	var roll := randi_range(1, 100)
	var total := 0
	for item in item_definitions:
		total += item.spawn_chance
		if roll <= total:
			room.add_item(item)
			return
	
func spawn_room(room_position: Vector2):
	var new_room = ROOM_SCENE.instantiate()
	
	new_room.position = room_position
	new_room.side_clicked.connect(_on_room_side_clicked)
	new_room.room_clicked.connect(_on_room_clicked)
	add_child(new_room)
	_spawn_item(new_room)
	
func _on_room_clicked(room):
	if not token.selected:
		return
	if move_tween and move_tween.is_running():
		return
	var offset: Vector2 = room.position - token.position
	if not (offset in [
		Vector2(0, -ROOM_SIZE.y),
		Vector2(ROOM_SIZE.x, 0),
		Vector2(0, ROOM_SIZE.y),
		Vector2(-ROOM_SIZE.x, 0)
	]):
		return
		
	move_tween = create_tween()
	move_tween.tween_property(
		token, "position", room.position, 0.4
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
func _on_room_side_clicked(room, direction: String):
	match direction:
		"north":
			if room.north_exit:
				return
			room.north_exit = true
			spawn_north_room(room)

		"south":
			if room.south_exit:
				return
			room.south_exit = true
			spawn_south_room(room)

		"east":
			if room.east_exit:
				return
			room.east_exit = true
			spawn_east_room(room)

		"west":
			if room.west_exit:
				return
			room.west_exit = true
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
