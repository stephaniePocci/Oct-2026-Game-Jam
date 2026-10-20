extends Node2D

const ROOM_SCENE = preload("res://scenes/Room.tscn")
const ROOM_SIZE := Vector2(256, 192)
const DIRECTIONS := {
	"north": Vector2i.UP,
	"east": Vector2i.RIGHT,
	"south": Vector2i.DOWN,
	"west": Vector2i.LEFT
}
const OPPOSITE := {
	"north": "south",
	"east": "west",
	"south": "north",
	"west": "east"
}

@export var item_definitions: Array[ItemDefinition] = []
@export var room_definitions: Array[RoomDefinition] = []

var token
var current_room
var move_tween: Tween
var item_chances_valid := true
var room_chances_valid := true
var rooms_by_cell: Dictionary = {}
var cells_by_room: Dictionary = {}
var board_origin: Vector2

func _ready() -> void:
	var starting_room = get_node("Room")
	token = get_node("CharacterToken")
	current_room = starting_room
	board_origin = starting_room.position
	item_chances_valid = _validate_item_chances()
	room_chances_valid = _validate_room_chances()
	starting_room.set_definition(_choose_room_definition())
	starting_room.set_entrances(_roll_entrances(Vector2i.ZERO, ""))
	_register_room(starting_room, Vector2i.ZERO)
	_spawn_item(starting_room)

func _register_room(room, cell: Vector2i) -> void:
	rooms_by_cell[cell] = room
	cells_by_room[room] = cell
	room.side_clicked.connect(_on_room_side_clicked)
	room.room_clicked.connect(_on_room_clicked)

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

func _validate_room_chances() -> bool:
	var total := 0
	for definition in room_definitions:
		if definition == null or definition.spawn_chance < 0 or definition.spawn_chance > 100:
			push_error("Each room type needs a spawn chance between 0% and 100%.")
			return false
		total += definition.spawn_chance
	if total > 100:
		push_error("Room type spawn chances must total no more than 100%.")
		return false
	return true

func _choose_room_definition() -> RoomDefinition:
	if not room_chances_valid:
		return null
	var roll := randi_range(1, 100)
	var total := 0
	for definition in room_definitions:
		total += definition.spawn_chance
		if roll <= total:
			return definition
	return null

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

func _roll_entrances(cell: Vector2i, required_direction: String) -> Array[String]:
	var entrances: Array[String] = []
	var optional: Array[String] = []
	if required_direction != "":
		entrances.append(required_direction)
	for direction in DIRECTIONS:
		if direction == required_direction:
			continue
		var neighbor = rooms_by_cell.get(cell + DIRECTIONS[direction])
		if neighbor == null:
			optional.append(direction)
		elif neighbor.has_entrance(OPPOSITE[direction]) and not neighbor.is_connected(OPPOSITE[direction]):
			entrances.append(direction)
	optional.shuffle()
	var target_count := randi_range(maxi(1, entrances.size()), entrances.size() + optional.size())
	for index in target_count - entrances.size():
		entrances.append(optional[index])
	return entrances

func _connect_neighbors(room, cell: Vector2i) -> void:
	for direction in DIRECTIONS:
		if not room.has_entrance(direction):
			continue
		var neighbor = rooms_by_cell.get(cell + DIRECTIONS[direction])
		var opposite: String = OPPOSITE[direction]
		if neighbor != null and neighbor.has_entrance(opposite) and not neighbor.is_connected(opposite):
			room.connect_room(direction, neighbor)
			neighbor.connect_room(opposite, room)

func spawn_room(cell: Vector2i, required_direction: String) -> void:
	if rooms_by_cell.has(cell):
		return
	var new_room = ROOM_SCENE.instantiate()
	new_room.position = board_origin + Vector2(cell.x * ROOM_SIZE.x, cell.y * ROOM_SIZE.y)
	new_room.set_definition(_choose_room_definition())
	new_room.set_entrances(_roll_entrances(cell, required_direction))
	add_child(new_room)
	_connect_neighbors(new_room, cell)
	_register_room(new_room, cell)
	_spawn_item(new_room)

func _on_room_clicked(room) -> void:
	if not token.selected or room == current_room:
		return
	if move_tween and move_tween.is_running():
		return
	for direction in DIRECTIONS:
		if current_room.connected_rooms.get(direction) == room:
			move_tween = create_tween()
			move_tween.tween_property(token, "position", room.position, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			move_tween.finished.connect(_on_move_finished.bind(room))
			return

func _on_move_finished(room) -> void:
	current_room = room

func _on_room_side_clicked(room, direction: String) -> void:
	if not DIRECTIONS.has(direction) or not room.has_entrance(direction) or room.is_connected(direction):
		return
	var cell: Vector2i = cells_by_room[room] + DIRECTIONS[direction]
	if rooms_by_cell.has(cell):
		return
	spawn_room(cell, OPPOSITE[direction])
