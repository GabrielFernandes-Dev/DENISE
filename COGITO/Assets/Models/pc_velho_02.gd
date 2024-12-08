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
            
            # Convertendo o ponto de colisão para o espaço local do monitor
            var local_point = monitor_mesh.global_transform.inverse() * result.position
            
            # Calculando UV baseado na normal do monitor
            var forward = Vector3(0, 0, 1)
            var right = Vector3(1, 0, 0)
            var up = Vector3(0, 1, 0)
            
            var x_proj = local_point.dot(right)
            var y_proj = local_point.dot(up)
            
            var uv = Vector2(
                (x_proj / 0.5 + 1.0) * 0.5,
                1.0 - ((y_proj / 0.5 + 1.0) * 0.5)
            )
            
            print("Projected coords - X: ", x_proj, " Y: ", y_proj)
            print("Calculated UV: ", uv)
            
            uv = uv.clamp(Vector2.ZERO, Vector2.ONE)
            
            var viewport_pos = Vector2(
                uv.x * viewport.size.x,
                uv.y * viewport.size.y
            )
            print("Viewport position: ", viewport_pos)
            
            # Criando eventos de mouse
            # Movimento do mouse
            var mouse_motion = InputEventMouseMotion.new()
            mouse_motion.position = viewport_pos
            viewport.push_input(mouse_motion)
            
            # Mouse button down
            var mouse_down = InputEventMouseButton.new()
            mouse_down.button_index = event.button_index
            mouse_down.pressed = true
            mouse_down.position = viewport_pos
            mouse_down.double_click = event.double_click
            viewport.push_input(mouse_down)
            
            # Mouse button up
            var mouse_up = InputEventMouseButton.new()
            mouse_up.button_index = event.button_index
            mouse_up.pressed = false
            mouse_up.position = viewport_pos
            mouse_up.double_click = event.double_click
            viewport.push_input(mouse_up)
            
            get_viewport().set_input_as_handled()
