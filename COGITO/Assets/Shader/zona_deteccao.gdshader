shader_type spatial;

uniform vec4 base_color : source_color = vec4(0.0, 0.7, 1.0, 0.3);
uniform vec4 grid_color : source_color = vec4(0.0, 1.0, 1.0, 0.5);
uniform float pulse_speed : hint_range(0.1, 5.0) = 0.7;
uniform float grid_size : hint_range(1.0, 50.0) = 20.0;
uniform float scan_line_speed : hint_range(0.1, 5.0) = 0.5;
uniform float scan_line_width : hint_range(0.0, 1.0) = 0.04;

void fragment() {
    vec2 grid_uv = UV * grid_size;
    vec2 grid_id = floor(grid_uv);
    vec2 grid_fd = fract(grid_uv);

    float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.8);

    float grid_lines = step(0.95, grid_fd.x) + step(0.95, grid_fd.y);

    float scan_line = step(scan_line_width, fract(UV.y - TIME * scan_line_speed));

    vec4 final_color = mix(base_color, grid_color, grid_lines * pulse);

    float distortion = sin(UV.y * 100.0 + TIME) * 0.01;

    ALBEDO = final_color.rgb + vec3(distortion);
    ALPHA = final_color.a;
    EMISSION = final_color.rgb * pulse;
}