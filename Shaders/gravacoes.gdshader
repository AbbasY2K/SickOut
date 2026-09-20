shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float contrast : hint_range(0.8, 1.5) = 1.02;
uniform float brightness : hint_range(0.8, 1.2) = 1.02;

void fragment() {
	vec3 col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

	// Contraste
	col = (col - 0.5) * contrast + 0.5;

	// Brilho
	col *= brightness;

	COLOR = vec4(col, 1.0);
}