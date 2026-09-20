shader_type canvas_item;

uniform vec4 main_color : source_color = vec4(0.2, 1.0, 0.3, 1.0);
uniform float glow_size = 3.0;
uniform float rgb_split = 1.5;
uniform float shake_amount = 0.8;

void fragment()
{
	vec2 shake = vec2(
		sin(TIME * 60.0 + UV.y * 50.0),
		cos(TIME * 50.0 + UV.x * 40.0)
	) * shake_amount * TEXTURE_PIXEL_SIZE;

	vec2 r_offset = vec2(-rgb_split, 0.0) * TEXTURE_PIXEL_SIZE;
	vec2 b_offset = vec2(rgb_split, 0.0) * TEXTURE_PIXEL_SIZE;

	float r = texture(TEXTURE, UV + shake + r_offset).a;
	float g = texture(TEXTURE, UV + shake).a;
	float b = texture(TEXTURE, UV + shake + b_offset).a;

	vec3 color = vec3(r, g, b);

	// Glow
	float glow = 0.0;

	for (float x = -glow_size; x <= glow_size; x++)
	{
		for (float y = -glow_size; y <= glow_size; y++)
		{
			glow += texture(TEXTURE, UV + vec2(x, y) * TEXTURE_PIXEL_SIZE).a;
		}
	}

	glow /= pow(glow_size * 2.0 + 1.0, 2.0);

	float pulse = 1.3 + 0.3 * sin(TIME * 8.0);

	// Scanlines
	float scan = 0.9 + 0.1 * sin(UV.y * 700.0);

	// Flicker
	float flicker = 0.95 + 0.05 * sin(TIME * 90.0);

	vec3 final =
		color * main_color.rgb * pulse * scan * flicker +
		main_color.rgb * glow * 1.5;

	COLOR.rgb = final;
	COLOR.a = max(g, glow * 0.4);
}