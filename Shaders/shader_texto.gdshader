shader_type canvas_item;

uniform float amplitude = .0;   // altura do pulo
uniform float speed = 5.0;       // velocidade
uniform float randomness = 2; // variação entre letras

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

void vertex() {
    // Identificador pseudo-único por letra
    float id = floor(VERTEX.x / 8.0);
    float random_offset = hash(id) * randomness;

    float t = TIME * speed + id * random_offset;

    // Movimento tipo quique (mais seco que seno)
    float bounce = abs(sin(t));

    VERTEX.y -= bounce * amplitude;
}