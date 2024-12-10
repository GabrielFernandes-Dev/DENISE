extends Node3D


@onready var mensagem_variaveis: Label3D = $mensagem_variaveis
@onready var mensagem_condicionais: Label3D = $mensagem_condicionais
@onready var mensagem_funcoes: Label3D = $mensagem_funcoes


@onready var mensagem_habilidade: Label3D = $mensagem_habilidade
@onready var mensagem_virus: Label3D = $mensagem_virus


func _ready() -> void:
    if CogitoSceneManager.is_returning_from_scene:
        load_game_state()
        CogitoSceneManager.is_returning_from_scene = false

    mensagem_variaveis.visible = false
    mensagem_condicionais.visible = false
    mensagem_funcoes.visible = false
    mensagem_habilidade.visible = false
    mensagem_virus.visible = false

func load_game_state():
    var current_position = CogitoSceneManager._current_player_node.global_position
    var current_rotation = CogitoSceneManager._current_player_node.global_rotation
    
    # Carrega os estados
    CogitoSceneManager.load_scene_state(get_tree().current_scene.get_name(), CogitoSceneManager._active_slot)
    CogitoSceneManager.load_player_state(CogitoSceneManager._current_player_node, CogitoSceneManager._active_slot)
    
    # Restaura a posição original
    CogitoSceneManager._current_player_node.global_position = current_position
    CogitoSceneManager._current_player_node.global_rotation = current_rotation

    # Função para quando o jogador entrar na área
func _on_area_variaveis_body_entered(_body: Node3D) -> void:
    mensagem_variaveis.visible = true

    # Função para quando o jogador sair da área
func _on_area_variaveis_body_exited(_body: Node3D) -> void:
    mensagem_variaveis.visible = false

func _on_area_condicionais_body_entered(_body: Node3D) -> void:
    mensagem_condicionais.visible = true

func _on_area_condicionais_body_exited(_body: Node3D) -> void:
    mensagem_condicionais.visible = false

func _on_area_funcoes_body_entered(_body: Node3D) -> void:
    mensagem_funcoes.visible = true

func _on_area_funcoes_body_exited(_body: Node3D) -> void:
    mensagem_funcoes.visible = false

func _on_area_habilidade_body_entered(_body: Node3D) -> void:
    mensagem_habilidade.visible = true

func _on_area_habilidade_body_exited(_body: Node3D) -> void:
    mensagem_habilidade.visible = false

func _on_area_virus_body_entered(_body: Node3D) -> void:
    mensagem_virus.visible = true

func _on_area_virus_body_exited(_body: Node3D) -> void:
    mensagem_virus.visible = false
