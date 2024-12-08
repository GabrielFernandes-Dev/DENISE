extends Node3D

func _ready() -> void:
    CogitoSceneManager.load_scene_state(get_tree().current_scene.get_name(), CogitoSceneManager._active_slot)
    CogitoSceneManager.load_player_state(CogitoSceneManager._current_player_node, CogitoSceneManager._active_slot)
