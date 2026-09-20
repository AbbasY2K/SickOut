shader_type canvas_item;

uniform vec4 cor_alvo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tolerancia : hint_range(0.0, 1.0) = 0.1;
uniform float suavidade : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    float dist = distance(tex.rgb, cor_alvo.rgb);

    float alpha = smoothstep(tolerancia, tolerancia + suavidade, dist);

    COLOR = vec4(tex.rgb, tex.a * alpha);
}