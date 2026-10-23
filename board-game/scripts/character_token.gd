extends Node2D

const TOKEN_RADIUS := 20.0
var selected := false
var health := 100
var trapped := false


func _draw() -> void:
	if selected:
		draw_circle(Vector2.ZERO, TOKEN_RADIUS + 5.0, Color.GOLD)
	draw_circle(Vector2.ZERO, TOKEN_RADIUS + 1.0, Color(0.16, 0.13, 0.12))


func contains_screen_point(screen_position: Vector2) -> bool:
	var local_position := get_global_transform_with_canvas().affine_inverse() * screen_position
	return local_position.length() <= TOKEN_RADIUS

func toggle_selected() -> void:
	selected = not selected
	queue_redraw()
