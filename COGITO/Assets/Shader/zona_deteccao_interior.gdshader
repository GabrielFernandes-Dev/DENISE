shader_type spatial;

uniform vec4 base_color : source_color = vec4(0.0, 0.7, 1.0, 0.3);
uniform vec4 grid_color : source_color = vec4(0.0, 1.0, 1.0, 0.5);
uniform vec4 outline_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float pulse_speed : hint_range(0.1, 5.0) = 1.0;
uniform float grid_size : hint_range(1.0, 50.0) = 20.0;
uniform float outline_thickness : hint_range(0.0, 0.1) = 0.02;
uniform bool player_inside = false;

void fragment() {
    // Grid pattern
    vec2 grid_uv = UV * grid_size;
    vec2 grid_id = floor(grid_uv);
    vec2 grid_fd = fract(grid_uv);

    // Pulse effect
    float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5);

    // Grid lines
    float grid_lines = step(0.95, grid_fd.x) + step(0.95, grid_fd.y);

    // Outline calculation
    float outline = 0.0;
    if (UV.x < outline_thickness || UV.x > 1.0 - outline_thickness ||
        UV.y < outline_thickness || UV.y > 1.0 - outline_thickness) {
        outline = 1.0;
    }

    // Final color calculation
    vec4 final_color;
    if (outline > 0.0) {
        // Outline is always visible
        final_color = outline_color;
        final_color.a *= pulse * 0.8 + 0.2; // Pulsing outline
    } else {
        // Interior is only visible when player is outside
        final_color = mix(base_color, grid_color, grid_lines * pulse);
        final_color.a *= player_inside ? 0.0 : 0.3; // Fade out when player is inside
    }

    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
    EMISSION = final_color.rgb * pulse * 0.5;
}