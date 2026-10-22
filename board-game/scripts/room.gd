extends Node2D

const ROOM_SIZE := Vector2(256, 192)
const ITEM_SIZE := Vector2(30, 36)
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
signal item_clicked(room, index: int)

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

func add_entrance(direction: String) -> void:
	match direction:
		"north": north_exit = true
		"east": east_exit = true
		"south": south_exit = true
		"west": west_exit = true
	queue_redraw()

func has_entrance(direction: String) -> bool:
	match direction:
		"north": return north_exit
		"east": return east_exit
		"south": return south_exit
		"west": return west_exit
	return false

func has_room_connection(direction: String) -> bool:
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

func take_item(index: int) -> ItemDefinition:
	if index < 0 or index >= items.size():
		return null
	var item: ItemDefinition = items[index]
	items.remove_at(index)
	queue_redraw()
	return item

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
		draw_rect(card_rect, Color(0.86, 0.72, 0.49), true)
		var artwork: Texture2D = items[index].map_art if items[index].map_art != null else items[index].item_art
		if artwork != null:
			var inner_rect := card_rect.grow(-3.0)
			var artwork_size := Vector2(artwork.get_size())
			var fitted_size := artwork_size * minf(inner_rect.size.x / artwork_size.x, inner_rect.size.y / artwork_size.y)
			draw_texture_rect(artwork, Rect2(inner_rect.get_center() - fitted_size / 2.0, fitted_size), false)
		draw_rect(card_rect, Color(0.21, 0.15, 0.09), false, 2.0)

func handle_click(screen_position: Vector2) -> void:
	var mouse_position := get_global_transform_with_canvas().affine_inverse() * screen_position
	for index in range(items.size() - 1, -1, -1):
		var card_rect := Rect2(ITEM_POSITIONS[index] - ITEM_SIZE / 2, ITEM_SIZE)
		if card_rect.has_point(mouse_position):
			item_clicked.emit(self, index)
			return
	for direction in SIDE_POSITIONS:
		if not has_entrance(direction):
			continue
		if mouse_position.distance_to(SIDE_POSITIONS[direction]) <= CIRCLE_RADIUS:
			if not has_room_connection(direction):
				side_clicked.emit(self, direction)
			return
	if Rect2(-ROOM_SIZE / 2, ROOM_SIZE).has_point(mouse_position):
		room_clicked.emit(self)
