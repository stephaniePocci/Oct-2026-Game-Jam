extends Control

@onready var menu_view: CenterContainer = $MenuView
@onready var help_view: CenterContainer = $HelpView

func _ready() -> void:
	$MenuView/MenuButtons/PlayButton.pressed.connect(_play)
	$MenuView/MenuButtons/HowToPlayButton.pressed.connect(_show_help)
	$MenuView/MenuButtons/QuitButton.pressed.connect(_quit)
	$HelpView/HelpPanel/MarginContainer/HelpContent/BackButton.pressed.connect(_show_menu)
	$MenuView/MenuButtons/PlayButton.grab_focus()

func _play() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _show_help() -> void:
	menu_view.hide()
	help_view.show()
	$HelpView/HelpPanel/MarginContainer/HelpContent/BackButton.grab_focus()

func _show_menu() -> void:
	help_view.hide()
	menu_view.show()
	$MenuView/MenuButtons/PlayButton.grab_focus()

func _quit() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if help_view.visible and event.is_action_pressed("ui_cancel"):
		_show_menu()
		get_viewport().set_input_as_handled()
