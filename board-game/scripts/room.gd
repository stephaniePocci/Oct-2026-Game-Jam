extends Node2D

const ROOM_SIZE := Vector2(256, 192)
const ITEM_SIZE := Vector2(24, 32)
const ITEM_POSITIONS := [
	Vector2(80, -48),
	Vector2(80, 48),
	Vector2(-80, -48),
	Vector2(-80, 48)
]
const CIRCLE_RADIUS := 12.0
const SIDE_POSITIONS := {
	"north": Vector2(0, -80),
	"south": Vector2(0, 80),
	"east": Vector2(112, 0),
	"west": Vector2(-112, 0)
}

@export var north_exit: bool = false
@export var east_exit: bool = false
@export var south_exit: bool = false
@export var west_exit: bool = false

signal side_clicked(room, direction: String)
signal room_clicked(room)

var definition: RoomDefinition
var connected_rooms: Dictionary = {}
var items: Array[ItemDefinition] = []

func set_definition(room_definition: RoomDefinition) -> void:
	definition = room_definition
	queue_redraw()

func set_entrances(directions: Array[String]) -> void:
	north_exit = directions.has("north")
	east_exit = directions.has("east")
	south_exit = directions.has("south")
	west_exit = directions.has("west")
	queue_redraw()

func has_entrance(direction: String) -> bool:
	match direction:
		"north": return north_exit
		"east": return east_exit
		"south": return south_exit
		"west": return west_exit
	return false

func has_connection(direction: String) -> bool:
	return connected_rooms.has(direction)

func connect_room(direction: String, room: Node2D) -> void:
	connected_rooms[direction] = room
	queue_redraw()

func add_item(item: ItemDefinition) -> bool:
	if item == null or items.size() >= ITEM_POSITIONS.size():
		return false
	items.append(item)
	queue_redraw()
	return true

func _draw() -> void:
	var room_rect := Rect2(-ROOM_SIZE / 2, ROOM_SIZE)
	var fill := definition.placeholder_color if definition != null else Color(0.25, 0.23, 0.22)
	draw_rect(room_rect, fill, true)
	if definition != null and definition.room_art != null:
		draw_texture_rect(definition.room_art, room_rect, false)
	draw_rect(room_rect, Color(0.8, 0.75, 0.65), false, 4.0)
	for direction in SIDE_POSITIONS:
		if has_entrance(direction):
			draw_circle(SIDE_POSITIONS[direction], CIRCLE_RADIUS, Color(0.9, 0.7, 0.3))
	for index in items.size():
		var card_rect := Rect2(ITEM_POSITIONS[index] - ITEM_SIZE / 2, ITEM_SIZE)
		draw_rect(card_rect, Color(0.2, 0.78, 0.32), true)
		draw_rect(card_rect, Color(0.08, 0.35, 0.12), false, 2.0)

func handle_click(screen_position: Vector2) -> void:
	var mouse_position := get_global_transform_with_canvas().affine_inverse() * screen_position
	for direction in SIDE_POSITIONS:
		if not has_entrance(direction):
			continue
		if mouse_position.distance_to(SIDE_POSITIONS[direction]) <= CIRCLE_RADIUS:
			if not has_connection(direction):
				side_clicked.emit(self, direction)
			return
	if Rect2(-ROOM_SIZE / 2, ROOM_SIZE).has_point(mouse_position):
		room_clicked.emit(self)
