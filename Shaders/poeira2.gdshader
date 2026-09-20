shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float scan_strength=0.08;
uniform float noise_strength=0.03;
uniform float vignette=0.35;
uniform float distortion=0.003;
uniform float flicker=0.03;

float rand(vec2 p){
    return fract(sin(dot(p,vec2(12.9898,78.233)))*43758.5453);
}

void fragment(){

    vec2 uv=SCREEN_UV;

    float wave=sin(uv.y*8.0+TIME*0.5)*distortion;

    uv.x+=wave;

    vec4 color=texture(SCREEN_TEXTURE,uv);

    float scan=sin(uv.y*900.0);

    color.rgb-=scan*scan_strength;

    float noise=rand(floor(uv*vec2(800.0,450.0))+TIME);

    color.rgb+=noise*noise_strength;

    float vig=distance(SCREEN_UV,vec2(0.5));

    color.rgb*=1.0-vig*vignette;

    float flick=1.0+sin(TIME*60.0)*flicker;

    color.rgb*=flick;

    COLOR=color;
}