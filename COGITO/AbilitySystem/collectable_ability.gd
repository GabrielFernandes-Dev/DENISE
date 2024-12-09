extends Area3D

@export var ability: GDScript:
    set(value):
        # Verifica se o script herda de CogitoAbility
        if value and value.new() is CogitoAbility:
            ability = value
        else:
            push_error("O script deve herdar de CogitoAbility")
    get:
        return ability  

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var new_ability = ability.new()

func _ready() -> void:
    add_to_group("Persist")
    var material = StandardMaterial3D.new()
    material.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
    material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
    material.albedo_color = Color(1, 1, 1, 1)
    material.albedo_texture = new_ability.icon
    material.billboard_mode = StandardMaterial3D.BILLBOARD_ENABLED  # opcional

    mesh_instance_3d.material_override = material

func _on_body_entered(body: Node3D) -> void:
    var quantidade_real = body.abilities.filter(func(ability_): return ability_ != null).size()
    body.add_ability(new_ability, quantidade_real)
    body.hot_bar.populate_hotbar()
    queue_free()

func save() -> Dictionary:
    return {
        "filename": scene_file_path,
        "parent": get_parent().get_path(),
        "pos_x": position.x,
        "pos_y": position.y,
        "pos_z": position.z,
        "rot_x": rotation.x,
        "rot_y": rotation.y,
        "rot_z": rotation.z,
        "collected": !is_inside_tree()
    }

func _enter_tree() -> void:
    if get("collected"):
        queue_free()
