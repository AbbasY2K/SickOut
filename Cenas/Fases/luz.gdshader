shader_type canvas_item;
render_mode blend_add;

uniform float intensity : hint_range(0.0, 1.0) = 0.35;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    COLOR = vec4(tex.rgb * intensity, tex.a * intensity);
}