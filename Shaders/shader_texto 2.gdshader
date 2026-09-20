shader_type canvas_item;

uniform float amplitude = 2.0;
uniform float speed = 5.0;

void vertex() {
    VERTEX.y += sin(TIME * speed + VERTEX.x * 0.1) * amplitude;
}