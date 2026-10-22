extends CanvasLayer

@onready var items_label: Label = $CharacterPanel/MarginContainer/Content/ItemsLabel
@onready var inventory_list: HBoxContainer = $CharacterPanel/MarginContainer/Content/InventoryList
@onready var inspect_overlay: ColorRect = $InspectOverlay
@onready var inspect_art: TextureRect = $InspectOverlay/InspectCard

var inventory_items: Array[ItemDefinition] = []

func _ready() -> void:
	for index in inventory_list.get_child_count():
		var slot := inventory_list.get_child(index) as PanelContainer
		var content := slot.get_node("Content") as VBoxContainer
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for child in content.get_children():
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.gui_input.connect(_on_slot_gui_input.bind(index))
	inspect_overlay.gui_input.connect(_on_overlay_gui_input)
	$InspectOverlay/CloseButton.pressed.connect(_close_inspection)

func update_inventory(items: Array[ItemDefinition]) -> void:
	inventory_items = items.duplicate()
	items_label.text = "Inventory Full (4/4)" if items.size() == inventory_list.get_child_count() else "Items (%d/4)" % items.size()
	for index in inventory_list.get_child_count():
		var slot := inventory_list.get_child(index) as PanelContainer
		var icon: TextureRect = slot.get_node("Content/Icon")
		if index < items.size():
			icon.texture = items[index].item_art
			slot.modulate = Color.WHITE
		else:
			icon.texture = null
			slot.modulate = Color(1, 1, 1, 0.55)

func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and index < inventory_items.size():
		inspect_art.texture = inventory_items[index].item_art
		inspect_overlay.show()

func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_close_inspection()

func _unhandled_input(event: InputEvent) -> void:
	if inspect_overlay.visible and event.is_action_pressed("ui_cancel"):
		_close_inspection()
		get_viewport().set_input_as_handled()

func _close_inspection() -> void:
	inspect_overlay.hide()
