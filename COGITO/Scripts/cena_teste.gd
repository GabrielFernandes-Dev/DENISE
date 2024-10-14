extends Node3D

var area1 = Vector3(1, 0, 5)
var area2 = Vector3(10, 0, -10)
var area3 = Vector3(10, 0, 10)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pos = area1 #adicionar lógica para definir área em que cada vírus de movimenta
	$Virus.get_area_main_scene(pos)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
