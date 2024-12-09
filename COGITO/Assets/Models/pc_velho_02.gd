extends Node3D

@onready var viewport: SubViewport = $SubViewport
@onready var camera: Camera3D = $"../camera_rig/camera"
@onready var monitor_mesh: MeshInstance3D = $Amiga/pc_velho/pc/tela
@onready var monitor_body: StaticBody3D = $Amiga/pc_velho/pc/tela/StaticBody3D

func _ready() -> void:
    # Configuração crucial do viewport
    viewport.gui_disable_input = false
    viewport.handle_input_locally = true
    
    print("Referencias carregadas:")
    print("Viewport: ", viewport)
    print("Camera: ", camera)
    print("Monitor Mesh: ", monitor_mesh)
    print("Monitor Body: ", monitor_body)
    
    var collision = monitor_body.get_child(0) as CollisionShape3D
    if collision:
        print("Collision shape type: ", collision.shape.get_class())

    # Adicionar bordas visíveis para a área clicável
    var debug_border = Control.new()
    viewport.add_child(debug_border)
    
    # Borda superior
    var top = ColorRect.new()
    top.position = Vector2(0, 0)
    top.size = Vector2(viewport.size.x, 2)
    top.color = Color.GREEN
    debug_border.add_child(top)
    
    # Borda inferior
    var bottom = ColorRect.new()
    bottom.position = Vector2(0, viewport.size.y - 2)
    bottom.size = Vector2(viewport.size.x, 2)
    bottom.color = Color.GREEN
    debug_border.add_child(bottom)
    
    # Borda esquerda
    var left = ColorRect.new()
    left.position = Vector2(0, 0)
    left.size = Vector2(2, viewport.size.y)
    left.color = Color.GREEN
    debug_border.add_child(left)
    
    # Borda direita
    var right = ColorRect.new()
    right.position = Vector2(viewport.size.x - 2, 0)
    right.size = Vector2(2, viewport.size.y)
    right.color = Color.GREEN
    debug_border.add_child(right)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        print("Mouse button event detectado: ", event.position)
        
        var from = camera.project_ray_origin(event.position)
        var to = from + camera.project_ray_normal(event.position) * 1000.0
        
        var space_state = get_world_3d().direct_space_state
        var query = PhysicsRayQueryParameters3D.create(from, to)
        var result = space_state.intersect_ray(query)
        
        if result and result.collider == monitor_body:
            print("Hit monitor!")
            
            # Convertendo o ponto de colisão e normal para o espaço local do monitor
            var local_point = monitor_mesh.global_transform.inverse() * result.position
            var local_normal = monitor_mesh.global_transform.basis.inverse() * result.normal
            
            # Definindo o plano da tela usando a normal
            var plane = Plane(Vector3.FORWARD, 0)  # Assumindo que a tela está alinhada com Z
            
            # Projetando o ponto no plano da tela
            var projected_point = local_point - (local_point.dot(plane.normal) * plane.normal)
            
            # Calculando dimensões da tela baseado no AABB
            var aabb = monitor_mesh.mesh.get_aabb()
            var screen_size = Vector2(aabb.size.x, aabb.size.y)
            
            # Calculando UV baseado na posição projetada
            var uv = Vector2(
                (projected_point.x - aabb.position.x) / aabb.size.x,
                1.0 - ((projected_point.y - aabb.position.y) / aabb.size.y)
            )
            
            print("\n=== Debug Detalhado ===")
            print("Local point: ", local_point)
            print("Local normal: ", local_normal)
            print("Projected point: ", projected_point)
            print("AABB: ", aabb)
            print("Screen size: ", screen_size)
            print("UV antes do clamp: ", uv)
            
            # Garantir que os UVs estão no intervalo correto
            uv = uv.clamp(Vector2.ZERO, Vector2.ONE)
            print("UV após clamp: ", uv)
            
            # Converter para coordenadas do viewport
            var viewport_pos = Vector2(
                uv.x * viewport.size.x,
                uv.y * viewport.size.y
            )
            
            print("Viewport position: ", viewport_pos)
            
            # Criar o ponto de debug visual
            if viewport_pos.x >= 0 and viewport_pos.x <= viewport.size.x and \
               viewport_pos.y >= 0 and viewport_pos.y <= viewport.size.y:
                var debug_point = ColorRect.new()
                viewport.add_child(debug_point)
                debug_point.position = viewport_pos - Vector2(2.5, 2.5)  # Centraliza o ponto
                debug_point.size = Vector2(5, 5)
                debug_point.color = Color.RED
                
                await get_tree().create_timer(2.0).timeout
                debug_point.queue_free()
            
            if viewport_pos.x < 0 or viewport_pos.x > viewport.size.x or \
            viewport_pos.y < 0 or viewport_pos.y > viewport.size.y:
                print("Clique fora dos limites do viewport!")
                return

            _debug_uv_coords(local_point, uv, viewport_pos)

            print("\n=== Viewport Debug ===")
            print("Viewport size: ", viewport.size)
            print("Click within bounds: ", Rect2(Vector2.ZERO, viewport.size).has_point(viewport_pos))

            var debug_point = ColorRect.new()
            viewport.add_child(debug_point)
            debug_point.position = viewport_pos
            debug_point.size = Vector2(5, 5)
            debug_point.color = Color.RED
            
            # Remove o ponto depois de 2 segundos
            await get_tree().create_timer(2.0).timeout
            debug_point.queue_free()

            var mouse_event = InputEventMouseButton.new()
            mouse_event.button_index = event.button_index
            mouse_event.pressed = true
            mouse_event.position = viewport_pos
            mouse_event.global_position = viewport_pos  # Importante definir ambos
            mouse_event.double_click = event.double_click

            viewport.push_input(mouse_event)

func _debug_uv_coords(local_point: Vector3, uv: Vector2, viewport_pos: Vector2):
    print("\n=== UV Debug ===")
    print("Local point: ", local_point)
    print("Monitor size: ", monitor_mesh.mesh.get_aabb().size if monitor_mesh.mesh else "Unknown")
    print("UV coords: ", uv)
    print("Viewport size: ", viewport.size)
    print("Final viewport position: ", viewport_pos)
    
    # Cria uma cruz para melhor visualização do ponto de clique
    var debug_cross = Control.new()
    viewport.add_child(debug_cross)
    
    var horizontal = ColorRect.new()
    horizontal.position = Vector2(viewport_pos.x - 10, viewport_pos.y)
    horizontal.size = Vector2(20, 1)
    horizontal.color = Color.BLUE
    debug_cross.add_child(horizontal)
    
    var vertical = ColorRect.new()
    vertical.position = Vector2(viewport_pos.x, viewport_pos.y - 10)
    vertical.size = Vector2(1, 20)
    vertical.color = Color.BLUE
    debug_cross.add_child(vertical)
    
    await get_tree().create_timer(2.0).timeout
    debug_cross.queue_free()
