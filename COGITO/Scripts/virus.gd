extends CharacterBody3D

@export var vel: float = 0.8
var moviment_area: Vector3
var dir: Vector3 = Vector3()

func set_direction(new_dir: Vector3) -> void:
	dir = new_dir

func _physics_process(delta: float) -> void:
	# Move o inimigo na direção atual
	var mov = dir * vel
	velocity = mov
	var collision = move_and_collide(velocity*delta)
	
	if collision:
		dir = -dir
	
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
						$RayCast3D.debug_shape_custom_color = Color(174, 0, 0)
						print('I see you')
					else:
						$RayCast3D.debug_shape_custom_color = Color(0, 255, 0)
						print("I don't see you")
