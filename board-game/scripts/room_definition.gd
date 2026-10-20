extends Resource
class_name RoomDefinition

@export var room_name: String = "Room"
@export var room_art: Texture2D
@export var placeholder_color: Color = Color(0.25, 0.23, 0.22)
@export_range(0, 100, 1, "suffix:%") var spawn_chance: int = 0
