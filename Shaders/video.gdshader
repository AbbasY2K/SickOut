shader_type canvas_item;
render_mode unshaded;

// CRT
uniform float scanline_strength : hint_range(0.0,0.3) = 0.05;

// VINHETA
uniform float vignette_strength : hint_range(0.0,1.0) = 0.3;
uniform float vignette_size : hint_range(0.1,1.0) = 0.7;
uniform float vignette_softness : hint_range(0.01,1.0) = 0.4;

// BORDAS ARREDONDADAS
uniform float corner_radius : hint_range(0.0,0.5) = 0.15;
uniform float edge_softness : hint_range(0.001,0.1) = 0.02;

void fragment() {

	vec2 uv = UV;
	vec2 resolution = vec2(textureSize(TEXTURE, 0));

	vec3 col = texture(TEXTURE, uv).rgb;

	// CRT - scanlines
	float scan = sin(uv.y * resolution.y * 3.14159);
	col -= scan * scanline_strength;

	// VINHETA
	float dist = distance(uv, vec2(0.5));
	float vignette = smoothstep(vignette_size, vignette_size - vignette_softness, dist);
	col *= mix(1.0, vignette, vignette_strength);

	// BORDAS ARREDONDADAS
	vec2 centered = uv - 0.5;
	vec2 abs_uv = abs(centered);

	vec2 box = vec2(0.5 - corner_radius);
	vec2 d = abs_uv - box;
	float dist_edge = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);

	float mask = 1.0 - smoothstep(0.0, edge_softness, dist_edge);

	col *= mask;

	COLOR = vec4(col, mask);
}