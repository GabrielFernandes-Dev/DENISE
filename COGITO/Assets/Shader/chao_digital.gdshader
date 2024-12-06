shader_type spatial;

uniform vec4 grid_color: source_color = vec4(0.0, 1.0, 0.7, 1.0);
uniform vec4 base_color: source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float grid_scale = 50.0;
uniform float line_thickness = 0.02;
uniform float fog_falloff = 1.5;

void fragment() {
    // Coordenadas da grade
    vec2 grid_uv = UV * grid_scale;
    
    // Linhas da grade
    vec2 grid_fract = fract(grid_uv);
    float grid_x = smoothstep(0.0, line_thickness, grid_fract.x) * 
                   smoothstep(line_thickness, 0.0, grid_fract.x);
    float grid_y = smoothstep(0.0, line_thickness, grid_fract.y) * 
                   smoothstep(line_thickness, 0.0, grid_fract.y);
    float grid = max(grid_x, grid_y);
    
    // Efeito de fade para o horizonte
    float dist_fade = 1.0 - clamp(length(UV - vec2(0.5)) * fog_falloff, 0.0, 1.0);
    
    // Cor final
    vec3 final_color = mix(base_color.rgb, grid_color.rgb, grid);
    
    ALBEDO = final_color;
    EMISSION = final_color * 0.5;
    METALLIC = 0.8;
    ROUGHNESS = 0.2;
}