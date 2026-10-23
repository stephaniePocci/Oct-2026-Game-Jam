extends SceneTree

const GAME = preload("res://scenes/game.tscn")
const LAUDANUM = preload("res://items/laudanum.tres")
const PIT = preload("res://items/bottomless_pit.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var menu = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu)
	menu._show_help()
	assert(menu.help_view.visible and not menu.menu_view.visible)
	menu._show_menu()
	assert(menu.menu_view.visible and not menu.help_view.visible)
	menu.queue_free()

	var game := GAME.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	var board = game.get_node("Board")
	var hud = game.get_node("HUD")

	board.token.health = 60
	hud.update_health(60)
	board.inventory.append(LAUDANUM)
	hud.update_inventory(board.inventory)
	hud.selected_index = 0
	hud._refresh_use_button()
	hud._on_use_pressed()
	assert(board.token.health == 85 and board.inventory.is_empty())

	board.token.health = 90
	hud.update_health(90)
	board.inventory.append(LAUDANUM)
	hud.update_inventory(board.inventory)
	hud.selected_index = 0
	hud._refresh_use_button()
	hud._on_use_pressed()
	assert(board.token.health == 100 and board.inventory.is_empty())

	board.inventory.append(LAUDANUM)
	hud.update_inventory(board.inventory)
	hud.selected_index = 0
	hud._refresh_use_button()
	hud._on_use_pressed()
	assert(board.inventory.size() == 1 and board.token.health == 100)

	board.inventory.clear()
	board.inventory.append(PIT)
	hud.update_inventory(board.inventory)
	board._on_item_use_requested(0)
	board._cancel_pit_placement()
	assert(board.inventory.size() == 1 and board.pit_rooms.is_empty())

	board._on_item_use_requested(0)
	board._place_pit(board.current_room)
	assert(board.inventory.is_empty() and board.pit_rooms.has(board.current_room))
	assert(not board.token.trapped)
	board._on_move_finished(board.current_room)
	assert(board.token.trapped and board.pit_rooms.is_empty())
	quit()
