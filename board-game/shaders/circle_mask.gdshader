shader_type canvas_item;

void fragment() {
	vec2 crop_uv = (UV / TEXTURE_PIXEL_SIZE - vec2(1016.0, 276.0)) / vec2(88.0, 88.0);
	float edge = length(crop_uv - vec2(0.5));
	COLOR.a *= 1.0 - smoothstep(0.46, 0.5, edge);
}
