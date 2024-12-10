extends Node3D

@onready var area_1 : Area3D = $NavigationRegion3D/Area1

func _ready() -> void:
	var current_position = CogitoSceneManager._current_player_node.global_position
	var current_rotation = CogitoSceneManager._current_player_node.global_rotation
	
	# Carrega os estados
	CogitoSceneManager.load_scene_state(get_tree().current_scene.get_name(), CogitoSceneManager._active_slot)
	CogitoSceneManager.load_player_state(CogitoSceneManager._current_player_node, CogitoSceneManager._active_slot)
	
	# Restaura a posição original
	CogitoSceneManager._current_player_node.global_position = current_position
	CogitoSceneManager._current_player_node.global_rotation = current_rotation

func _process(_delta: float) -> void:
	if area_1.contar_inimigos() == 0 :
		print("area limpa")
