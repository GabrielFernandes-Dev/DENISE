shader_type spatial;
render_mode unshaded, depth_draw_always, depth_prepass_alpha;

const float PI_number = 3.1415926535;

uniform vec3 shift = vec3(0.0, 0.0, 0.0);
uniform vec3 time_shift_scale = vec3(0.0, 0.0, 0.0); // Modified to move right to left
uniform vec4 scan_color = vec4(0.0, 0.3, 1.0, 1.0);
uniform float scan_line_width : hint_range(0.0, 1.0) = 0.1;
uniform float scan_line_size = 0.8;
uniform vec4 background_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Added black background color

varying vec3 local_vertex;

float get_ratio_scan_line(float p)
{
    return max(
        -sin(mod(p, scan_line_size) / scan_line_size * PI_number) + scan_line_width,
        0.0
    ) / scan_line_width;
}

void vertex( )
{
	local_vertex = VERTEX + shift + time_shift_scale * TIME;
}

void fragment()
{
    float v = clamp(
        get_ratio_scan_line(local_vertex.x)
        + get_ratio_scan_line(local_vertex.y)
        + get_ratio_scan_line(local_vertex.z),
        0.0,
        1.0
    );

    // Blend the scan color with the background color
    ALBEDO = mix(background_color.rgb, scan_color.rgb, v);
    ALPHA = 1.0; // Set alpha to 1.0 to remove transparency
}