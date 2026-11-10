
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float strength : hint_range(0.0, 1.0) = 1.0;

uniform float pulse_speed : hint_range(0.1, 5.0) = 1.8;
uniform float green_intensity : hint_range(0.0, 0.2) = 0.075;

void fragment() {
	vec2 uv = SCREEN_UV;
	float t = TIME;

	vec2 center = uv - vec2(0.5);
	float radius = length(center);

	vec2 radial_dir = center / max(radius, 0.0001);

	// Distorção circular
	float radial_wave = sin(radius * 25.0 - t * 5.0) * 0.0018;

	// Ondulações horizontais e verticais
	float wave_x = sin(uv.y * 36.0 + t * 6.0) * 0.0018;
	float wave_y = cos(uv.x * 29.0 - t * 4.5) * 0.001;

	uv += (
		radial_dir * radial_wave +
		vec2(wave_x, wave_y)
	) * strength;

	vec2 sample_uv = clamp(uv, vec2(0.001), vec2(0.999));

	// Aberração cromática
	float chroma = 0.0013 * strength * (0.6 + radius);

	float red = texture(
		screen_texture,
		clamp(sample_uv + vec2(chroma, 0.0), vec2(0.001), vec2(0.999))
	).r;

	vec4 original = texture(screen_texture, sample_uv);

	float blue = texture(
		screen_texture,
		clamp(sample_uv - vec2(chroma, 0.0), vec2(0.001), vec2(0.999))
	).b;

	vec3 color = vec3(red, original.g, blue);

	// Pulsação verde tóxica
	float pulse = 0.5 + 0.5 * sin(t * pulse_speed);

	float greenPulse = strength * green_intensity * (0.35 + pulse * 0.65);

	vec3 greenTint = color * vec3(0.88, 1.08, 0.91);

	color = mix(color, greenTint, greenPulse);

	// Brilho verde nas áreas mais claras
	float brightness = dot(
		color,
		vec3(0.299, 0.587, 0.114)
	);

	float highlights = smoothstep(0.3, 0.85, brightness);

	color += vec3(0.0, 0.035, 0.012) * pulse * strength * highlights;

	// Tonalidade roxa nas extremidades
	float vignette = smoothstep(0.25, 0.75, radius);

	vec3 purpleTint = color * vec3(0.84, 0.72, 0.98);

	color = mix(
		color,
		purpleTint,
		vignette * strength * 0.16
	);

	COLOR = vec4(color, 1.0);
}
