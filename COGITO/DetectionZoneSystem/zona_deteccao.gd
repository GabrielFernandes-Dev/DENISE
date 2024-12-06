extends Area3D

@onready var collision_shape = $CollisionShape3D
@onready var mesh_instance = $MeshInstance3D

# Lista para armazenar referências dos inimigos
var inimigos_presentes : Array = []
var jogador : CharacterBody3D = null
	
# Chamado quando um corpo entra na área
func _on_body_entered(body:Node3D) -> void:
	if body.is_in_group("virus"):  # Se o corpo é um inimigo
		inimigos_presentes.append(body)
	elif body.is_in_group("player"):  # Verifique se o corpo é o jogador
		jogador = body

# Chamado quando um corpo sai da área
func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("virus"):  # Se o corpo é um inimigo
		inimigos_presentes.erase(body)
	elif body.is_in_group("player"):  # Se o corpo é o jogador
		jogador = null

# Função para contar o número de inimigos na área
func contar_inimigos() -> int:
	return inimigos_presentes.size()

# Função para verificar se o jogador está na área
func jogador_na_area() -> bool:
	return jogador != null
