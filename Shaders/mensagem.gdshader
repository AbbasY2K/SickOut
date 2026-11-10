
shader_type canvas_item;

uniform float intensidade : hint_range(0.0, 1.0) = 0.75;
uniform float scanlines : hint_range(0.0, 1.0) = 0.45;
uniform float velocidade : hint_range(1.0, 30.0) = 18.0;
uniform float distorcao : hint_range(0.0, 0.1) = 0.025;
uniform vec4 cor_glitch : source_color = vec4(0.75, 0.25, 1.0, 1.0);

float hash(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float tempo = floor(TIME * velocidade);
	float linha = floor(UV.y * 240.0);

	float ruido = hash(linha + tempo * 13.0);
	float falha = step(0.88, hash(floor(TIME * 9.0)));

	float deslocamento = (ruido - 0.5) * distorcao * intensidade;
	deslocamento += (hash(tempo) - 0.5) * distorcao * 2.0 * falha;

	uv.x += deslocamento;

	vec4 tex = texture(TEXTURE, uv) * COLOR;

	float scan = 0.5 + 0.5 * sin(UV.y * 1100.0);
	tex.rgb *= 1.0 - scan * scanlines;

	float glitch = step(0.94, hash(linha + tempo * 7.0));
	tex.rgb = mix(tex.rgb, tex.rgb * cor_glitch.rgb, glitch * intensidade);

	float flash = step(0.985, hash(floor(TIME * 13.0)));
	tex.rgb += cor_glitch.rgb * flash * intensidade * 0.45 * tex.a;

	float corte = step(0.97, hash(linha + floor(TIME * 20.0)));
	tex.a *= 1.0 - corte * intensidade * 0.65;

	COLOR = tex;
}
