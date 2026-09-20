shader_type canvas_item;

uniform float reveal : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Revelação da esquerda para a direita
	if (UV.x > reveal) {
		tex.a = 0.0;
	}

	// Compensa o CanvasModulate #9b9b9b
	tex.rgb /= vec3(0.6078);

	COLOR = tex;
}