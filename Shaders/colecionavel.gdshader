shader_type canvas_item;

uniform float hover_speed = 2.0;
uniform float hover_amount = 3.0;

uniform float glitch_speed = 25.0;
uniform float glitch_strength = 0.035;
uniform float rgb_split = 0.008;

// Ativado pelo GDScript quando o item é coletado
uniform bool pickup_glitch = false;

float rand(vec2 co){
	return fract(sin(dot(co, vec2(12.9898,78.233))) * 43758.5453);
}

void vertex() {
	// Hover
	VERTEX.y += sin(TIME * hover_speed) * hover_amount;
}

void fragment() {
	vec2 uv = UV;

	float strength = glitch_strength;
	float split = rgb_split;
	float flicker_min = 0.8;
	float flicker_max = 1.3;
	float flash_chance = 0.96;

	// Glitch muito mais forte durante a coleta
	if (pickup_glitch) {
		strength *= 5.0;
		split *= 4.0;
		flicker_min = 0.3;
		flicker_max = 2.2;
		flash_chance = 0.55;
	}

	// Glitch por linhas
	float line = floor(uv.y * 80.0);
	float noise = rand(vec2(line, floor(TIME * glitch_speed)));

	if (noise > 0.65) {
		uv.x += (noise - 0.5) * strength;
	}

	// Tremidas
	float burst = step(0.92, rand(vec2(floor(TIME * 12.0), 7.0)));
	uv.x += sin(uv.y * 120.0 + TIME * 40.0) * strength * burst * 2.5;

	// Glitch extra durante a coleta
	if (pickup_glitch) {
		uv.x += sin(uv.y * 320.0 + TIME * 90.0) * 0.08;
		uv.y += cos(uv.x * 180.0 + TIME * 70.0) * 0.02;
	}

	// RGB Split
	float r = texture(TEXTURE, uv + vec2(split, 0.0)).r;
	float g = texture(TEXTURE, uv).g;
	float b = texture(TEXTURE, uv - vec2(split, 0.0)).b;
	float a = texture(TEXTURE, uv).a;

	vec4 col = vec4(r, g, b, a);

	// Flicker
	float flicker = mix(
		flicker_min,
		flicker_max,
		rand(vec2(floor(TIME * 40.0), 5.0))
	);
	col.rgb *= flicker;

	// Flashes
	float flash = rand(vec2(floor(TIME * 18.0), 3.0));
	if (flash > flash_chance) {
		col.rgb = vec3(1.0);
	}

	// Pequenos blocos corrompidos durante a coleta
	if (pickup_glitch) {
		float block = rand(vec2(floor(uv.y * 40.0), floor(TIME * 60.0)));
		if (block > 0.75) {
			col.rgb = vec3(
				rand(vec2(TIME, uv.y)),
				rand(vec2(uv.x, TIME)),
				rand(vec2(TIME * 2.0, uv.x))
			);
		}
	}

	COLOR = col;
}