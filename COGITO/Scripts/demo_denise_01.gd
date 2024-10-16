extends Node3D

@export var virus1: CharacterBody3D
#@export var enemy2: NodePath

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	# Atribuir direções aleatórias aos inimigos
	var direction1 = Vector3(randf_range(0, 0.5), 0, randf_range(-0.5,0)).normalized()
	#gerar direções para outros vírus presentes na cena
	#var direction2 = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	
	$virus.set_direction(direction1)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
