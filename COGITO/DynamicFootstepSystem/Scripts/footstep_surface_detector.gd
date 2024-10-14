extends AudioStreamPlayer3D

class_name FootstepSurfaceDetector

@export var generic_fallback_footstep_profile : AudioStreamRandomizer
@export var footstep_material_library : FootstepMaterialLibrary
var last_result

func _ready():
	if not generic_fallback_footstep_profile:
		printerr("FootstepSurfaceDetector - No generic fallback footstep profile is assigned")

func play_footstep():
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + Vector3(0, -1, 0))
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		
		last_result = result
		if _play_by_footstep_surface(result.collider):
			return
		elif _play_by_material(result.collider):
			return
		#if no material, play generics
		else:
			_play_footstep(generic_fallback_footstep_profile)

func _play_by_footstep_surface(collider : Node3D) -> bool:
	#check for footstep surface as a child of the collider
	var footstep_surface_child : AudioStreamRandomizer = _get_footstep_surface_child(collider)
	#if a child footstep surface was found, then play the sound defined by it
	if footstep_surface_child:
		_play_footstep(footstep_surface_child)
		return true
	#handle footstep surface settings
	elif collider is FootstepSurface and collider.footstep_profile:
		_play_footstep(collider.footstep_profile)
		return true
	return false

func _play_by_material(collider : Node3D) -> bool:
	# if no footstep surface, see if we can get a material
	if footstep_material_library:
		#find surface material
		var material : Material = _get_surface_material(collider)
		#if a material was found
		if material:
			#get a profile from our library
			var footstep_profile = footstep_material_library.get_footstep_profile_by_material(material)
			#found profile, use it
			if footstep_profile:
				_play_footstep(footstep_profile)
				return true
	return false

func _get_footstep_surface_child(collider : Node3D) -> AudioStreamRandomizer:
	#find all children of the collider static body that are of type "FootstepSurface"
	var footstep_surfaces = collider.find_children("", "FootstepSurface")
	if footstep_surfaces:
		#use the first footstep_surface child found
		return footstep_surfaces[0].footstep_profile
	return null

func _get_surface_material(collider : Node3D) -> Material:
	var mesh_instance = null
	var meshes = []
	if collider is CSGShape3D:
		if collider is CSGCombiner3D:
			#composite mesh
			if collider.material_override:
				return collider.material_override
			meshes = collider.get_meshes()
		else:
			return collider.material
	elif collider is StaticBody3D or collider is RigidBody3D:
		#find all children of the collider static body that are of type "MeshInstance3D"
		#if there are multiple materials, just default to the first one found
		if collider.get_parent() is MeshInstance3D:
			mesh_instance = collider.get_parent()
		else:
			var mesh_instances = collider.find_children("", "MeshInstance3D")
			if mesh_instances:
				if len(mesh_instances) == 1:
					mesh_instance = mesh_instances[0]
				else:
					meshes = mesh_instances
	
	if meshes:
		#TODO: Handle multiple meshes
		mesh_instance = meshes[0]
	
	if mesh_instance and 'mesh' in mesh_instance:
		var mesh = mesh_instance.mesh
		if mesh.get_surface_count() == 0:
			return null
		elif mesh.get_surface_count() == 1:
			return mesh.surface_get_material(0)
		else:
			var face = null
			
			var ray = last_result['position'] - global_position
			var faces = mesh.get_faces()
			
			var aabb = mesh.get_aabb() as AABB
			var accuracy = round(4*aabb.size.length_squared()) # dynamically calculate a reasonable grid size
			var snap = aabb.size/accuracy # this will be the size of our units to snap to
			
			var coord = null
			
			for i in range(len(faces) / 3):
				# first, figure out what face we're standing on
				var face_idx = i * 3
				var a = mesh_instance.to_global(faces[face_idx])
				var b = mesh_instance.to_global(faces[face_idx+1])
				var c = mesh_instance.to_global(faces[face_idx+2])
				var ray_t = Geometry3D.ray_intersects_triangle(global_position,ray,a,b,c)
				if ray_t:
					face = faces.slice(face_idx,face_idx+3)
					# round out vert coordinates to avoid floating point errors
					coord = [round(faces[face_idx]/snap),round(faces[face_idx+1]/snap),round(faces[face_idx+2]/snap)]
					break
			var mat = null
			if face:
				for surface in range(mesh.get_surface_count()):
					var surf = mesh.surface_get_arrays(surface)[0]
					var has_vert_a = false
					var has_vert_b = false
					var has_vert_c = false
					for vert in surf:
						var vert_coord = round(vert/snap)
						has_vert_a = has_vert_a or vert_coord == coord[0]
						has_vert_b = has_vert_b or vert_coord == coord[1]
						has_vert_c = has_vert_c or vert_coord == coord[2]
						if has_vert_a and has_vert_b and has_vert_c:
							# we found it! note the material and break free!
							mat = mesh.surface_get_material(surface)
							break
					if has_vert_a and has_vert_b and has_vert_c:
						break
			return mat
	return null

func _play_footstep(footstep_profile : AudioStreamRandomizer):
	stream = footstep_profile
	play()
