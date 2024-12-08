shader_type spatial;
render_mode unshaded, depth_draw_always, depth_prepass_alpha;

// Modified colors to dark purple
uniform vec4 light_color = vec4(0.2, 0.0, 0.3, 1.0);  // Darker purple
uniform vec4 arc_color = vec4(0.4, 0.0, 0.7, 1.0);
uniform vec2 seed = vec2(0.0, 0.0);
uniform float speed = 2.1;
uniform float random_scale = 0.6;
uniform float electro_scale = 10.459;

vec2 random(vec2 pos)
{
    return fract(
        sin(
            vec2(
                dot(pos, vec2(12.9898,78.233))
            ,   dot(pos, vec2(-148.998,-65.233))
            )
        ) * 43758.5453
    );
}

float value_noise(vec2 pos)
{
    vec2 p = floor(pos);
    vec2 f = fract(pos);
    float v00 = random(p + vec2(0.0, 0.0)).x;
    float v10 = random(p + vec2(1.0, 0.0)).x;
    float v01 = random(p + vec2(0.0, 1.0)).x;
    float v11 = random(p + vec2(1.0, 1.0)).x;
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(v00, v10, u.x), mix(v01, v11, u.x), u.y);
}

float noise_tex(vec2 p)
{
    return (
        value_noise(p * 0.984864) * 0.5
    +   value_noise(p * 2.543) * 0.25
    +   value_noise(p * 9.543543) * 0.125
    +   value_noise(p * 21.65436) * 0.0625
    +   value_noise(p * 42.0) * 0.03125
    +   value_noise(p * 87.135148) * 0.015625
    +   value_noise(p * 340.66534654) * 0.0078125
    );
}

void fragment()
{
    vec2 uv = seed + vec2(UV.x + cos(TIME * 1321.21 + UV.y * 348.513) * 0.004, UV.y + sin(TIME * 421.21 + UV.x * 314.513) * 0.0016);
    float f = abs(cos(TIME * speed + noise_tex(uv * random_scale) * electro_scale));

    // Mix between dark purple colors and black background
    vec3 final_color = mix(light_color, arc_color, 1.0 - clamp((f - 0.08) * 20.0, 0.0, 1.0)).rgb;
    float intensity = 1.0 - clamp((f - 0.3) * 3.0, 0.0, 1.0);

    // Mix with black background
    ALBEDO = mix(vec3(0.0), final_color, intensity);
    ALPHA = 1.0; // Solid alpha
}