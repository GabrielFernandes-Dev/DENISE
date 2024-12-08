extends Node3D

func _ready() -> void:
    if CogitoSceneManager.is_returning_from_scene:
        load_game_state()
        CogitoSceneManager.is_returning_from_scene = false

func load_game_state():
    CogitoSceneManager.load_scene_state(get_tree().current_scene.get_name(), CogitoSceneManager._active_slot)
    CogitoSceneManager.load_player_state(CogitoSceneManager._current_player_node, CogitoSceneManager._active_slot)
