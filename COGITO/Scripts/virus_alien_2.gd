extends CharacterBody3D


@export var speed : int = 7
@export var accel : int = 10

@onready var nav_agent: NavigationAgent3D = $virus_alien2/NavigationAgent3D

var current_target_index = 0

var points = [
	Vector3(-9,1,-2),
	Vector3(19, 1, -2)
	
]

func _ready() -> void:
	add_to_group("virus")
	nav_agent = NavigationAgent3D.new()
	add_child(nav_agent)

	# Configure o agente
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5

	await get_tree().create_timer(0.1).timeout
	
	position = points[0]

	# Define o primeiro destino
	set_next_target()

func set_next_target() -> void:
	if NavigationServer3D.get_maps().size() > 0:
		nav_agent.set_target_position(points[current_target_index])

func _physics_process(delta: float) -> void:
	if not nav_agent.is_target_reachable():
		return

	if nav_agent.is_navigation_finished():
		print("Final do caminho")
		current_target_index = (current_target_index + 1) % points.size()
		set_next_target()
		return

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()

	# Atualiza a velocidade suavizada
	velocity = velocity.lerp(direction * speed, accel * delta)

	# Move o personagem
	move_and_slide()
	
func _on_vision_timer_timeout() -> void:
	var overlaps = $VisionArea.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == "player":
				var playerPosition = overlap.global_transform.origin
				$RayCast3D.look_at(playerPosition, Vector3.UP)
				$RayCast3D.force_raycast_update()
				
				if $RayCast3D.is_colliding():
					var collider = $RayCast3D.get_collider()
					print('collider name: ', collider.name)
					if collider.name == "player":
						collider.decrease_attribute("health", 5)
						$RayCast3D.debug_shape_custom_color = Color(174, 0, 0)
					else:
						$RayCast3D.debug_shape_custom_color = Color(0, 255, 0)
func _eliminar():
	queue_free()
