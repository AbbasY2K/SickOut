shader_type canvas_item;

uniform float particle_count = 45.0;
uniform float particle_size = 0.0035;
uniform float speed = 0.05;
uniform float glow = 1.1;

float rand(float n){
	return fract(sin(n) * 43758.5453123);
}

void fragment(){

	vec2 uv = UV;
	vec3 col = vec3(0.0);

	float t = TIME * speed;

	// Correção de aspecto
	vec2 aspect = vec2(TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x, 1.0);

	for(float i = 0.0; i < 45.0; i++){

		if(i >= particle_count)
			break;

		float seed = i * 13.731;

		// Profundidade
		float depth = 0.45 + rand(seed + 60.0);

		// Posição inicial
		float x = rand(seed);
		float y = rand(seed + 5.0);

		// Movimento
		x += sin(t + seed) * 0.08;
		x += sin(t * 0.35 + seed * 4.0) * 0.015;

		y += cos(t * 0.8 + seed) * 0.12;

		// Velocidade diferente para cada partícula
		y = fract(y + t * (0.08 + depth * 0.22));

		vec2 pos = vec2(x, y);

		vec2 diff = (uv - pos) * aspect;
		float dist = dot(diff, diff);

		// Tamanho
		float size = particle_size * (0.6 + depth);

		// Núcleo
		float core = smoothstep(
			size * size,
			(size * 0.2) * (size * 0.2),
			dist
		);

		// Halo
		float halo = smoothstep(
			(size * 3.0) * (size * 3.0),
			(size * 0.4) * (size * 0.4),
			dist
		);

		float particle = core + halo * 0.2;

		// Brilho
		float brightness = 0.5 + rand(seed + 9.0) * glow;

		// Pulsação
		brightness *=
			0.85 +
			0.15 *
			sin(
				TIME *
				(1.5 + rand(seed) * 2.0)
				+ seed
			);

		// Algumas ficam naturalmente mais fracas
		brightness *= mix(
			0.45,
			1.0,
			rand(seed + 100.0)
		);

		// Piscar
		float blink =
			0.75 +
			0.25 *
			sin(
				TIME *
				(2.0 + rand(seed + 200.0))
				+ seed * 3.0
			);

		particle *= brightness * blink * depth;

		col += vec3(particle);
	}

	// Névoa sutil
	float fog =
		sin(UV.x * 6.0 + TIME * 0.08) *
		sin(UV.y * 4.0 - TIME * 0.05);

	fog = fog * 0.02 + 0.015;

	col += fog;

	col = clamp(col, 0.0, 1.0);

	COLOR = vec4(col, col.r);
}