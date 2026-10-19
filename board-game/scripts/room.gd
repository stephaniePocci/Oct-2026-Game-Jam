extends Node2D

const ROOM_SIZE := Vector2(256, 192)
const ITEM_SIZE := Vector2(24, 32)
const ITEM_POSITIONS := [
	Vector2(80, -48),
	Vector2(80, 48),
	Vector2(-80, -48),
	Vector2(-80, 48)
]

var items: Array[ItemDefinition] = []

@export var north_exit: bool = false
@export var east_exit: bool = false
@export var south_exit: bool = false
@export var west_exit: bool = false

signal side_clicked(room, direction: String)
signal room_clicked(room)
const CIRCLE_RADIUS := 12.0
const SIDE_POSITIONS := {
	"north": Vector2(0,-80),
	"south": Vector2(0,80),
	"east": Vector2(112,0),
	"west": Vector2(-112, 0)
	}

func add_item(item: ItemDefinition) -> bool:
	if item == null or items.size() >= ITEM_POSITIONS.size():
		return false
	items.append(item)
	queue_redraw()
	return true

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
	
	for circle_position in SIDE_POSITIONS.values():
		draw_circle(
			circle_position,
			CIRCLE_RADIUS,
			Color(0.9,0.7,0.3)
		)

	for index in items.size():
		var card_rect := Rect2(ITEM_POSITIONS[index] - ITEM_SIZE / 2, ITEM_SIZE)
		draw_rect(card_rect, Color(0.2, 0.78, 0.32), true)
		draw_rect(card_rect, Color(0.08, 0.35, 0.12), false, 2.0)

func _unhandled_input(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
		
	var mouse_position = get_local_mouse_position()
	
	for direction in SIDE_POSITIONS:
		var circle_position = SIDE_POSITIONS[direction]
		
		if mouse_position.distance_to(circle_position) <= CIRCLE_RADIUS:
			get_viewport().set_input_as_handled()
			side_clicked.emit(self, direction)
			return
			
	if Rect2(-ROOM_SIZE / 2, ROOM_SIZE).has_point(mouse_position):
		get_viewport().set_input_as_handled()
		room_clicked.emit(self)
