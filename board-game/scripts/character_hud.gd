extends CanvasLayer

const LAUDANUM = preload("res://items/laudanum.tres")

signal use_requested(index: int)

@onready var items_label: Label = $CharacterPanel/MarginContainer/Content/ItemsLabel
@onready var inventory_list: HBoxContainer = $CharacterPanel/MarginContainer/Content/InventoryList
@onready var health_label: Label = $CharacterPanel/MarginContainer/Content/CharacterRow/CharacterDetails/HealthLabel
@onready var health_bar: ProgressBar = $CharacterPanel/MarginContainer/Content/CharacterRow/CharacterDetails/HealthBar
@onready var inspect_overlay: ColorRect = $InspectOverlay
@onready var inspect_art: TextureRect = $InspectOverlay/InspectCard
@onready var use_button: Button = $InspectOverlay/UseButton
@onready var status_label: Label = $StatusLabel

var inventory_items: Array[ItemDefinition] = []
var selected_index := -1

func _ready() -> void:
	for index in inventory_list.get_child_count():
		var slot := inventory_list.get_child(index) as PanelContainer
		var content := slot.get_node("Content") as VBoxContainer
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for child in content.get_children():
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.gui_input.connect(_on_slot_gui_input.bind(index))
	inspect_overlay.gui_input.connect(_on_overlay_gui_input)
	$InspectOverlay/CloseButton.pressed.connect(close_inspection)
	use_button.pressed.connect(_on_use_pressed)

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
	if selected_index >= inventory_items.size():
		close_inspection()
	else:
		_refresh_use_button()

func update_health(health: int) -> void:
	health_bar.value = health
	health_label.text = "Health: %d%%" % health
	_refresh_use_button()

func set_pit_targeting(active: bool) -> void:
	$CharacterPanel.visible = not active
	if active:
		show_status("Choose a room for the pit. Esc or right-click to cancel.")
	else:
		status_label.hide()

func show_status(message: String) -> void:
	status_label.text = message
	status_label.show()

func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and index < inventory_items.size():
		selected_index = index
		inspect_art.texture = inventory_items[index].item_art
		_refresh_use_button()
		inspect_overlay.show()

func _refresh_use_button() -> void:
	if selected_index >= 0 and selected_index < inventory_items.size():
		use_button.disabled = inventory_items[selected_index] == LAUDANUM and health_bar.value >= 100

func _on_use_pressed() -> void:
	if selected_index >= 0 and not use_button.disabled:
		use_requested.emit(selected_index)

func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		close_inspection()

func _unhandled_input(event: InputEvent) -> void:
	if inspect_overlay.visible and event.is_action_pressed("ui_cancel"):
		close_inspection()
		get_viewport().set_input_as_handled()

func close_inspection() -> void:
	inspect_overlay.hide()
	selected_index = -1
