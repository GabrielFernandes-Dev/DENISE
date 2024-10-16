shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture;
uniform vec2 uv_scale = vec2(4.28, 1.86); // Uniform to control UV scaling

void fragment() {
    vec2 scaled_uv = vec2(UV.y, UV.x) * uv_scale; // Apply scaling to the UVs
    ALBEDO = texture(screen_texture, scaled_uv).rgb;
}