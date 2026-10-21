extends CanvasLayer

@onready var inventory_list: VBoxContainer = $CharacterPanel/MarginContainer/Content/InventoryScroll/InventoryList

func add_item(item: ItemDefinition) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(36, 44)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = item.item_art
	row.add_child(icon)
	var name_label := Label.new()
	name_label.text = item.item_name
	name_label.add_theme_color_override("font_color", Color(0.94, 0.87, 0.73))
	row.add_child(name_label)
	inventory_list.add_child(row)
