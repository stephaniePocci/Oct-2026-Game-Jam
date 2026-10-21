extends Resource
class_name ItemDefinition

@export var item_name: String = "Item"
@export_range(0, 100, 1, "suffix:%") var spawn_chance: int = 0
@export var item_art: Texture2D
