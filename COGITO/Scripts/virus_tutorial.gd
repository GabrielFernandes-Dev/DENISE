extends CharacterBody3D

@export var speed : int = 2
@export var accel : int = 10

var lua_script = """
--O virus depende da bool para viver
--troque a variavel para ativo "false" para desativar
local WormVirus = {
	ativo = true
}

function WormVirus:exec(self)
	return 	self.ativo
end
"""



var current_target_index = 0

var points = [
	Vector3(-1, 0.2, -5.5),
	Vector3(2, 0.2,-10),
	Vector3(26, 0.2,-9),
	Vector3(26, 0.2,0),
	Vector3(26, 0.2,-9)
	
]

func _ready() -> void:
	add_to_group("virus")


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
						
func _eliminar():
	queue_free()
