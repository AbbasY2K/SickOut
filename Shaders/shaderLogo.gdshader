shader_type canvas_item;

uniform float wave_strength : hint_range(0.0, 30.0) = 8.0;
uniform float wave_speed : hint_range(0.0, 10.0) = 2.5;
uniform float wave_frequency : hint_range(0.0, 20.0) = 8.0;

uniform float glow_strength : hint_range(0.0, 2.0) = 0.35;
uniform float color_shift : hint_range(0.0, 1.0) = 0.15;

void vertex() {
	float t = TIME * wave_speed;

	float wave_x = sin((UV.y * wave_frequency) + t) * wave_strength;
	float wave_y = cos((UV.x * wave_frequency * 0.7) + t * 1.2) * (wave_strength * 0.35);

	VERTEX.x += wave_x;
	VERTEX.y += wave_y;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float pulse = sin(TIME * 2.0 + UV.y * 8.0) * 0.5 + 0.5;

	vec3 shifted = tex.rgb;

	shifted.r += pulse * color_shift;
	shifted.b += (1.0 - pulse) * color_shift * 0.6;

	vec3 glow = shifted * (1.0 + glow_strength * pulse);

	COLOR = vec4(glow, tex.a);
}