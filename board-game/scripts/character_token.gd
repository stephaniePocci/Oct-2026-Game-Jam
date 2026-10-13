extends Node2D

const TOKEN_RADIUS := 20.0
var selected := false


func _draw() -> void:
	if selected:
		draw_circle(Vector2.ZERO, TOKEN_RADIUS + 5.0, Color.GOLD)
	draw_circle(Vector2.ZERO, TOKEN_RADIUS, Color.CRIMSON)


func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	if get_local_mouse_position().length() > TOKEN_RADIUS:
		return

	selected = not selected
	queue_redraw()
	get_viewport().set_input_as_handled()
