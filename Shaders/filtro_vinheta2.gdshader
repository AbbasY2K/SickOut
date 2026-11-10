
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// Scanlines
uniform float scanline_strength : hint_range(0.0, 0.08) = 0.018;
uniform float scanline_density : hint_range(0.5, 3.0) = 1.25;
uniform float scanline_speed : hint_range(0.0, 5.0) = 0.8;
uniform float scanline_wave : hint_range(0.0, 1.0) = 0.35;
uniform float scanline_pulse : hint_range(0.0, 1.0) = 0.25;
uniform float scanline_bands : hint_range(0.0, 1.0) = 0.30;

// Vinheta
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.45;
uniform float vignette_size : hint_range(0.1, 1.0) = 0.40;
uniform float vignette_softness : hint_range(0.01, 1.0) = 0.45;

// Imagem
uniform float contrast : hint_range(0.8, 1.5) = 1.06;
uniform float brightness : hint_range(0.5, 1.2) = 1.0;
uniform float chroma_shift : hint_range(0.0, 0.003) = 0.0003;

// Efeitos
uniform float static_strength : hint_range(0.0, 0.05) = 0.002;
uniform float glitch_strength : hint_range(0.0, 0.03) = 0.0015;
uniform float flicker_strength : hint_range(0.0, 0.03) = 0.002;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 resolution = vec2(textureSize(SCREEN_TEXTURE, 0));

	// Glitch raro
	float glitchLine = step(
		0.998,
		sin(TIME * 1.5 + uv.y * 30.0)
	);

	if (glitchLine > 0.0) {
		uv.x += sin(TIME * 70.0 + uv.y * 100.0) * glitch_strength;
	}

	// Aberração cromática
	float r = texture(
		SCREEN_TEXTURE,
		uv + vec2(chroma_shift, 0.0)
	).r;

	float g = texture(SCREEN_TEXTURE, uv).g;

	float b = texture(
		SCREEN_TEXTURE,
		uv - vec2(chroma_shift, 0.0)
	).b;

	vec3 col = vec3(r, g, b);

	// Coordenada vertical em pixels
	float line_pos = SCREEN_UV.y * resolution.y * scanline_density;

	// Linhas com bordas definidas e intensidade variável
	float line_phase = line_pos * 3.14159265;
	float scan = 0.5 + 0.5 * cos(line_phase);

	// Ondulação orgânica que percorre as linhas
	float wave = sin(
		SCREEN_UV.y * 18.0
		- TIME * scanline_speed * 2.0
		+ sin(TIME * 1.3 + SCREEN_UV.y * 9.0) * 1.5
	);

	float wave_mod = 1.0 + wave * scanline_wave * 0.45;

	// Pulsos de intensidade com ritmos diferentes
	float pulse_a = 0.5 + 0.5 * sin(
		TIME * 2.0 - SCREEN_UV.y * 24.0
	);

	float pulse_b = 0.5 + 0.5 * sin(
		TIME * 3.7 + SCREEN_UV.y * 11.0
	);

	float pulse = mix(
		1.0,
		0.65 + pulse_a * 0.25 + pulse_b * 0.25,
		scanline_pulse
	);

	// Faixa luminosa móvel
	float band_pos = fract(TIME * scanline_speed * 0.12);

	float band_dist = abs(SCREEN_UV.y - band_pos);
	band_dist = min(band_dist, 1.0 - band_dist);

	float band = exp(-band_dist * 35.0);

	// Segunda faixa, mais larga e mais suave
	float band2 = exp(
		-abs(SCREEN_UV.y - fract(band_pos + 0.45)) * 14.0
	);

	float band_mod = 1.0 + (
		band * 0.20 + band2 * 0.07
	) * scanline_bands;

	// Pequenas irregularidades entre linhas
	float line_id = floor(line_pos);

	float irregularity = random(vec2(line_id, 7.31));
	float line_variation = mix(
		0.88 + irregularity * 0.24,
		1.0,
		1.0 - scanline_wave
	);

	float scan_intensity = scan
		* wave_mod
		* pulse
		* band_mod
		* line_variation;

	col *= 1.0 - scan_intensity * scanline_strength;

	// Ruído
	float noise = random(vec2(
		floor(uv.x * resolution.x),
		floor(uv.y * resolution.y + TIME * 20.0)
	));

	col += (noise - 0.5) * static_strength;

	// Flicker
	float flicker = 1.0
		+ sin(TIME * 12.0) * flicker_strength;

	col *= flicker;

	// Vinheta suavizada
	float dist = distance(SCREEN_UV, vec2(0.5));

	float vignette = 1.0 - smoothstep(
		vignette_size,
		vignette_size + vignette_softness,
		dist
	);

	float edge_darkness = mix(0.35, 1.0, vignette);

	col *= mix(
		1.0,
		edge_darkness,
		vignette_strength
	);

	// Iluminação central
	col *= 1.0 + vignette * 0.06;

	// Contraste e brilho
	col = (col - 0.5) * contrast + 0.5;
	col *= brightness;

	COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
}
