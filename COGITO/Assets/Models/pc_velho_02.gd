extends Node3D

@onready var viewport: SubViewport = $SubViewport
@onready var sprite_3d: Sprite3D = $Amiga/pc_velho/pc/tela/ViewportSprite3D
@onready var camera: Camera3D = $"../camera_rig/camera"
@onready var static_body: StaticBody3D = $Amiga/pc_velho/pc/tela/ViewportSprite3D/StaticBody3D
@onready var collision_shape: CollisionShape3D = $Amiga/pc_velho/pc/tela/ViewportSprite3D/StaticBody3D/CollisionShape3D

var debug_mesh: MeshInstance3D

func _ready() -> void:
    # Configurar o viewport
    viewport.gui_disable_input = false
    viewport.handle_input_locally = true
    
    # Configurar o Sprite3D
    sprite_3d.transparent = true
    sprite_3d.shaded = false
    sprite_3d.double_sided = false
    sprite_3d.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
    sprite_3d.render_priority = 1


    
func _create_debug_mesh() -> void:
    var mesh = BoxMesh.new()
    mesh.size = (collision_shape.shape as BoxShape3D).size
    
    debug_mesh = MeshInstance3D.new()
    debug_mesh.mesh = mesh
    debug_mesh.position = collision_shape.position
    
    var material = StandardMaterial3D.new()
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.albedo_color = Color(1, 0, 0, 0.3)
    debug_mesh.material_override = material
    
    static_body.add_child(debug_mesh)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        print("\n=== Ray Debug ===")
        var screen_pos = event.position
        print("Screen Position:", screen_pos)
        
        var space_state = get_world_3d().direct_space_state
        var from = camera.project_ray_origin(screen_pos)
        var to = from + camera.project_ray_normal(screen_pos) * 100.0
        
        # Debug ray visualização
        _draw_debug_ray(from, to)
        
        print("Ray Origin:", from)
        print("Ray Direction:", camera.project_ray_normal(screen_pos))
        
        var query = PhysicsRayQueryParameters3D.create(from, to)
        query.collision_mask = 1  # Certifique-se que corresponde à collision_layer do StaticBody3D
        var result = space_state.intersect_ray(query)
        
        print("Ray Result:", result)
        
        if result:
            if result.collider == static_body:
                print("Hit monitor screen!")
                var hit_pos = result.position
                _handle_screen_click(hit_pos)
            else:
                print("Hit something else:", result.collider.name)

func _draw_debug_ray(from: Vector3, to: Vector3) -> void:
    var im = ImmediateMesh.new()
    var mi = MeshInstance3D.new()
    mi.mesh = im
    add_child(mi)
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color.GREEN
    material.emissive = Color.GREEN
    material.no_depth_test = true
    mi.material_override = material
    
    im.clear_surfaces()
    im.surface_begin(Mesh.PRIMITIVE_LINES)
    im.surface_add_vertex(from)
    im.surface_add_vertex(to)
    im.surface_end()
    
    # Remover após 2 segundos
    await get_tree().create_timer(2.0).timeout
    mi.queue_free()

func _handle_screen_click(hit_pos: Vector3) -> void:
    # Converter a posição do hit para coordenadas locais do Sprite3D
    var local_pos = sprite_3d.global_transform.inverse() * hit_pos
    
    # Converter para coordenadas UV
    var sprite_size = Vector2(1.0, 0.75) # Ajuste conforme necessário
    var uv = Vector2(
        (local_pos.x / sprite_size.x + 0.5),
        (-local_pos.y / sprite_size.y + 0.5)
    )
    
    # Converter para coordenadas do viewport
    var viewport_pos = Vector2(
        uv.x * viewport.size.x,
        uv.y * viewport.size.y
    )
    
    print("Local Position:", local_pos)
    print("UV Coordinates:", uv)
    print("Viewport Position:", viewport_pos)
    
    # Criar e enviar o evento de mouse
    var mouse_event = InputEventMouseButton.new()
    mouse_event.button_index = MOUSE_BUTTON_LEFT
    mouse_event.pressed = true
    mouse_event.position = viewport_pos
    mouse_event.global_position = viewport_pos
    
    viewport.push_input(mouse_event)
