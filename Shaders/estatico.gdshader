shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;

uniform float distortion : hint_range(0.0, 0.08) = 0.032;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.68;
uniform float scanline_strength : hint_range(0.0, 0.7) = 0.32;
uniform float chromatic_shift : hint_range(0.0, 0.02) = 0.006;
uniform float tracking_strength : hint_range(0.0, 0.08) = 0.035;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	vec2 uv = SCREEN_UV;

	float frame_id = floor(TIME * 28.0);
	float row = floor(uv.y * 540.0);

	float line_noise = hash21(vec2(row, frame_id));

	float band = step(
		0.965,
		hash21(vec2(
			floor(uv.y * 42.0),
			floor(TIME * 14.0)
		))
	);

	float tear_sign = sign(
		hash21(vec2(
			floor(uv.y * 42.0),
			frame_id + 7.0
		)) - 0.5
	);

	float jitter = (line_noise - 0.5) * distortion;
	jitter += band * tear_sign * tracking_strength;

	uv.x += jitter;
	uv = clamp(uv, vec2(0.001), vec2(0.999));

	vec2 rgb_offset = vec2(chromatic_shift, 0.0);

	vec2 uv_red = clamp(
		uv + rgb_offset,
		vec2(0.001),
		vec2(0.999)
	);

	vec2 uv_blue = clamp(
		uv - rgb_offset,
		vec2(0.001),
		vec2(0.999)
	);

	vec3 original = texture(screen_texture, SCREEN_UV).rgb;

	vec3 distorted = vec3(
		texture(screen_texture, uv_red).r,
		texture(screen_texture, uv).g,
		texture(screen_texture, uv_blue).b
	);

	float grain = hash21(
		floor(SCREEN_UV * vec2(640.0, 360.0))
		+ vec2(frame_id * 17.0, frame_id * 7.0)
	);

	float snow = step(0.985, grain) * 0.6;

	distorted += (grain - 0.5) * noise_strength;
	distorted += snow;

	float scanline = 0.5 + 0.5 * sin(SCREEN_UV.y * 850.0);

	distorted *= 1.0 - scanline * scanline_strength;

	float tracking_line = 1.0 - smoothstep(
		0.0,
		0.003,
		abs(SCREEN_UV.y - fract(TIME * 0.32))
	);

	distorted += tracking_line * vec3(0.12, 0.20, 0.26);

	distorted = mix(
		distorted,
		distorted * vec3(1.15, 0.82, 0.94),
		0.30
	);

	float flicker = 0.96 + 0.04 * sin(TIME * 70.0);
	distorted *= flicker;

	vec3 final_color = mix(original, distorted, intensity);

	COLOR = vec4(final_color, 1.0);
}