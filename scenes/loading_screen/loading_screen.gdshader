shader_type canvas_item;

uniform vec3 multiply_color: source_color;

void fragment() {
	COLOR.rgb = vec3(1.0, 1.0, 1.0) * multiply_color;
}
