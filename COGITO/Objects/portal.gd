extends Node3D

@export_file("*.tscn") var target_scene: String
@export var connector_name: String = ""
@export var portal_name: String = "Portal"

func _on_portal_body_entered(body: Node3D) -> void:
    if body.is_in_group("Player"):
        _initiate_scene_transition()    

# Gerencia a transição de cena
func _initiate_scene_transition() -> void:
    if target_scene.is_empty():
        push_warning("Portal '%s' não tem uma cena de destino configurada!" % portal_name)
        return

    # Salva o estado atual antes da transição
    var current_scene_name = get_tree().current_scene.get_name()
    CogitoSceneManager.save_scene_state(current_scene_name, CogitoSceneManager._active_slot)
    CogitoSceneManager.save_player_state(CogitoSceneManager._current_player_node, CogitoSceneManager._active_slot)

    CogitoSceneManager.is_returning_from_scene = true

    # Inicia a transição para a nova cena usando o CogitoSceneManager
    CogitoSceneManager.load_next_scene(
        target_scene,
        connector_name,
        CogitoSceneManager._active_slot,  # Usa o slot ativo atual
        CogitoSceneManager.CogitoSceneLoadMode.LOAD_SAVE
    )
