shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// CRT leve
uniform float scanline_strength : hint_range(0.0, 0.05) = 0.008;
uniform float scanline_density : hint_range(0.5, 2.0) = 1.0;

// Vinheta
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.25;
uniform float vignette_size : hint_range(0.1, 1.0) = 0.6;
uniform float vignette_softness : hint_range(0.01, 1.0) = 0.4;

// Imagem
uniform float contrast : hint_range(0.8, 1.5) = 1.02;
uniform float brightness : hint_range(0.8, 1.2) = 1.02;
uniform float chroma_shift : hint_range(0.0, 0.003) = 0.0003;

// Efeitos
uniform float static_strength : hint_range(0.0, 0.05) = 0.003;
uniform float glitch_strength : hint_range(0.0, 0.03) = 0.0015;
uniform float flicker_strength : hint_range(0.0, 0.03) = 0.003;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {

	vec2 uv = SCREEN_UV;
	vec2 resolution = vec2(textureSize(SCREEN_TEXTURE, 0));

	// Glitch extremamente raro
	float glitchLine = step(0.998, sin(TIME * 1.5 + uv.y * 30.0));

	if (glitchLine > 0.0) {
		uv.x += sin(TIME * 70.0 + uv.y * 100.0) * glitch_strength;
	}

	// Aberração cromática leve
	float r = texture(SCREEN_TEXTURE, uv + vec2(chroma_shift, 0.0)).r;
	float g = texture(SCREEN_TEXTURE, uv).g;
	float b = texture(SCREEN_TEXTURE, uv - vec2(chroma_shift, 0.0)).b;

	vec3 col = vec3(r, g, b);

	// Scanlines quase imperceptíveis e SEM animação
	float scan = sin(uv.y * resolution.y * scanline_density);
	scan = scan * 0.5 + 0.5;

	col *= 1.0 - (scan * scanline_strength);

	// Ruído muito leve
	float noise = random(
		vec2(
			floor(uv.x * resolution.x),
			floor(uv.y * resolution.y + TIME * 20.0)
		)
	);

	col += (noise - 0.5) * static_strength;

	// Flicker mínimo
	float flicker = 1.0 + sin(TIME * 12.0) * flicker_strength;
	col *= flicker;

	// Vinheta suave
	float dist = distance(uv, vec2(0.5));

	float vignette = smoothstep(
		vignette_size,
		vignette_size - vignette_softness,
		dist
	);

	col *= mix(1.0, max(vignette, 0.85), vignette_strength);

	// Contraste e brilho
	col = (col - 0.5) * contrast + 0.5;
	col *= brightness;

	COLOR = vec4(col, 1.0);
}