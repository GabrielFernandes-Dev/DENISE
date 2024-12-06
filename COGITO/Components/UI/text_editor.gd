extends Node3D

@onready var display = $display
@onready var area = $area
@onready var viewport = $viewport

var mesh_size = Vector2()
var mouse_entered = false
var mouse_held = false
var mouse_inside = false
var last_mouse_pos_3d = null
var last_mouse_pos_2d = null

func find_mouse(pos:Vector2):
	var camera = get_viewport().get_camera_3d()

	var dss:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	var rayparam = PhysicsRayQueryParameters3D.new()
	rayparam.from = camera.project_ray_origin(pos)
	var dis =  5
	rayparam.to = rayparam.from + camera.project_ray_normal(pos) * dis
	rayparam.collide_with_bodies = false
	rayparam.collide_with_areas = true

	var result = dss.intersect_ray(rayparam)
	
	if result.size() > 0:
		return result.position
	else:
		return null


func handle_mouse_event(event):
	mesh_size = display.mesh.size

	if event is InputEventMouseButton or event is InputEventScreenTouch:
		mouse_held = event.pressed
	
	var mouse_pos3d = find_mouse(event.global_position)
	mouse_inside = mouse_pos3d != null

	if mouse_inside:
		mouse_pos3d = area.global_transform.affine_inverse() * mouse_pos3d
		last_mouse_pos_3d = mouse_pos3d
	else:
		mouse_pos3d = last_mouse_pos_3d 
		if mouse_pos3d == null:
			mouse_pos3d = Vector3.ZERO

	var mouse_pos2d = Vector2(mouse_pos3d.x, -mouse_pos3d.y)

	mouse_pos2d.x += mesh_size.x / 2
	mouse_pos2d.y += mesh_size.y / 2

	mouse_pos2d.x = mouse_pos2d.x / mesh_size.x
	mouse_pos2d.y = mouse_pos2d.y / mesh_size.y

	mouse_pos2d.x = mouse_pos2d.x * viewport.size.x
	mouse_pos2d.y = mouse_pos2d.y * viewport.size.y

	event.position = mouse_pos2d
	event.global_position = mouse_pos2d

	if event is InputEventMouseMotion:
		if last_mouse_pos_2d == null:
			event.relative = Vector2(0, 0)
		else:
			event.relative = mouse_pos2d - last_mouse_pos_2d

	last_mouse_pos_2d = mouse_pos2d
	viewport.push_input(event)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.mouse_entered.connect(func(): mouse_entered = true)
	viewport.set_process_input(true)


func _unhandled_input(event: InputEvent) -> void:
	var is_mouse_event = false
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		is_mouse_event = true

	if mouse_entered and (is_mouse_event or mouse_held):
		handle_mouse_event(event)
	elif not is_mouse_event:
		viewport.push_input(event, true)
