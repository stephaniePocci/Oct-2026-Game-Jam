extends Node2D

const ROOM_SCENE = preload("res://scenes/Room.tscn")
const ROOM_SIZE := Vector2(256, 192)
const DRAG_THRESHOLD := 8.0
const ZOOM_STEP := 1.1
const MIN_ZOOM := 0.5
const MAX_ZOOM := 3.0
const MAX_INVENTORY_ITEMS := 4
const LAUDANUM = preload("res://items/laudanum.tres")
const BOTTOMLESS_PIT = preload("res://items/bottomless_pit.tres")
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

@onready var camera: Camera2D = $Camera2D
@onready var hud = $"../HUD"

var token
var current_room
var move_tween: Tween
var item_chances_valid := true
var room_chances_valid := true
var inventory: Array[ItemDefinition] = []
var rooms_by_cell: Dictionary = {}
var cells_by_room: Dictionary = {}
var board_origin: Vector2
var mouse_down := false
var dragging := false
var press_position := Vector2.ZERO
var pending_pit_index := -1
var hovered_pit_room
var pit_rooms: Dictionary = {}

func _ready() -> void:
	var starting_room = get_node("Room")
	token = get_node("CharacterToken")
	current_room = starting_room
	board_origin = starting_room.position
	camera.position = board_origin
	item_chances_valid = _validate_item_chances()
	room_chances_valid = _validate_room_chances()
	starting_room.set_definition(_choose_room_definition())
	starting_room.set_entrances(_roll_entrances(Vector2i.ZERO, ""))
	_register_room(starting_room, Vector2i.ZERO)
	_spawn_item(starting_room)
	call_deferred("_setup_hud")

func _setup_hud() -> void:
	hud.use_requested.connect(_on_item_use_requested)
	hud.update_health(token.health)

func _unhandled_input(event: InputEvent) -> void:
	if pending_pit_index >= 0:
		if event.is_action_pressed("ui_cancel"):
			_cancel_pit_placement()
			get_viewport().set_input_as_handled()
			return
		if event is InputEventMouseMotion:
			_set_hovered_pit_room(_room_at_screen_position(event.position))
			get_viewport().set_input_as_handled()
			return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_cancel_pit_placement()
			get_viewport().set_input_as_handled()
			return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				_place_pit(_room_at_screen_position(event.position))
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				_zoom_at(event.position, event.button_index == MOUSE_BUTTON_WHEEL_UP)
				get_viewport().set_input_as_handled()
			return
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if event.pressed:
			mouse_down = true
			dragging = false
			press_position = event.position
		else:
			if mouse_down and not dragging:
				_click_at(event.position)
			mouse_down = false
			dragging = false
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and mouse_down:
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
			mouse_down = false
			dragging = false
			return
		if not dragging and event.position.distance_to(press_position) >= DRAG_THRESHOLD:
			dragging = true
		if dragging:
			camera.position -= event.relative / camera.zoom.x
			get_viewport().set_input_as_handled()

func _zoom_at(screen_position: Vector2, zoom_in: bool) -> void:
	var old_zoom := camera.zoom.x
	var new_zoom := clampf(old_zoom * (ZOOM_STEP if zoom_in else 1.0 / ZOOM_STEP), MIN_ZOOM, MAX_ZOOM)
	if is_equal_approx(old_zoom, new_zoom):
		return
	var before := get_global_transform_with_canvas().affine_inverse() * screen_position
	camera.zoom = Vector2.ONE * new_zoom
	camera.force_update_scroll()
	var after := get_global_transform_with_canvas().affine_inverse() * screen_position
	camera.position += before - after
	camera.force_update_scroll()

func _click_at(screen_position: Vector2) -> void:
	if token.contains_screen_point(screen_position):
		if not token.trapped:
			token.toggle_selected()
		return
	var room = _room_at_screen_position(screen_position)
	if room != null:
		room.handle_click(screen_position)

func _room_at_screen_position(screen_position: Vector2):
	var board_position := get_global_transform_with_canvas().affine_inverse() * screen_position
	var offset := board_position - board_origin + ROOM_SIZE / 2.0
	var cell := Vector2i(floori(offset.x / ROOM_SIZE.x), floori(offset.y / ROOM_SIZE.y))
	return rooms_by_cell.get(cell)

func _register_room(room, cell: Vector2i) -> void:
	rooms_by_cell[cell] = room
	cells_by_room[room] = cell
	room.side_clicked.connect(_on_room_side_clicked)
	room.room_clicked.connect(_on_room_clicked)
	room.item_clicked.connect(_on_item_clicked)

func _on_item_clicked(room, index: int) -> void:
	if room != current_room or (move_tween and move_tween.is_running()) or inventory.size() >= MAX_INVENTORY_ITEMS:
		return
	var item: ItemDefinition = room.take_item(index)
	if item != null:
		inventory.append(item)
		hud.update_inventory(inventory)

func _on_item_use_requested(index: int) -> void:
	if index < 0 or index >= inventory.size():
		return
	var item: ItemDefinition = inventory[index]
	if item == LAUDANUM:
		if token.health >= 100:
			return
		token.health = mini(token.health + 25, 100)
		hud.update_health(token.health)
	elif item == BOTTOMLESS_PIT:
		pending_pit_index = index
		hud.close_inspection()
		hud.set_pit_targeting(true)
		_set_hovered_pit_room(_room_at_screen_position(get_viewport().get_mouse_position()))
		return
	inventory.remove_at(index)
	hud.close_inspection()
	hud.update_inventory(inventory)

func _set_hovered_pit_room(room) -> void:
	if room != null and pit_rooms.has(room):
		room = null
	if hovered_pit_room == room:
		return
	if hovered_pit_room != null:
		hovered_pit_room.pit_target_hovered = false
		hovered_pit_room.queue_redraw()
	hovered_pit_room = room
	if hovered_pit_room != null:
		hovered_pit_room.pit_target_hovered = true
		hovered_pit_room.queue_redraw()

func _place_pit(room) -> void:
	if room == null or pit_rooms.has(room):
		return
	if pending_pit_index >= inventory.size() or inventory[pending_pit_index] != BOTTOMLESS_PIT:
		_cancel_pit_placement()
		return
	pit_rooms[room] = true
	inventory.remove_at(pending_pit_index)
	hud.update_inventory(inventory)
	_cancel_pit_placement()

func _cancel_pit_placement() -> void:
	pending_pit_index = -1
	_set_hovered_pit_room(null)
	hud.set_pit_targeting(false)
	if token.trapped:
		hud.show_status("The pit trapped your character. Movement is no longer possible.")

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
		elif not neighbor.has_room_connection(OPPOSITE[direction]):
			if neighbor.has_entrance(OPPOSITE[direction]):
				entrances.append(direction)
			else:
				optional.append(direction)
	optional.shuffle()
	var target_count := randi_range(maxi(2, entrances.size()), entrances.size() + optional.size())
	for index in target_count - entrances.size():
		entrances.append(optional[index])
	return entrances

func _connect_neighbors(room, cell: Vector2i) -> void:
	for direction in DIRECTIONS:
		if not room.has_entrance(direction):
			continue
		var neighbor = rooms_by_cell.get(cell + DIRECTIONS[direction])
		var opposite: String = OPPOSITE[direction]
		if neighbor != null and not neighbor.has_room_connection(opposite):
			if not neighbor.has_entrance(opposite):
				neighbor.add_entrance(opposite)
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
	if not token.selected or token.trapped or room == current_room:
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
	if pit_rooms.has(room):
		pit_rooms.erase(room)
		token.trapped = true
		token.selected = false
		token.queue_redraw()
		hud.show_status("The pit trapped your character. Movement is no longer possible.")

func _on_room_side_clicked(room, direction: String) -> void:
	if room != current_room or (move_tween and move_tween.is_running()):
		return
	if not DIRECTIONS.has(direction) or not room.has_entrance(direction) or room.has_room_connection(direction):
		return
	var cell: Vector2i = cells_by_room[room] + DIRECTIONS[direction]
	if rooms_by_cell.has(cell):
		return
	spawn_room(cell, OPPOSITE[direction])
