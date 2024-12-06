extends CogitoAttribute

@export var memory_regen_speed : float = 256
@export var regenerate_after : float = 2
@export var auto_regenerate : bool = true

var regen_timer : Timer
var stamina_regen_wait : float
var is_regenerating : bool
var player : Node3D

@onready var detection_zone = get_node_or_null("../../NavigationRegion3D/Area1") 

func _ready() -> void:
	value_current = value_start
	player = get_parent()
	
	if detection_zone == null:
		push_error("ZonaDeteccao não encontrada! Verifique a estrutura dos nodes.")
		return

	regen_timer = Timer.new()
	regen_timer.wait_time = regenerate_after
	add_child(regen_timer)
	regen_timer.timeout.connect(_on_regen_timer_timeout)


func _process(delta):
	if is_regenerating:
		add(memory_regen_speed * delta)
		if value_current >= value_max:
			is_regenerating = false

 	# Só regenera se o jogador estiver fora da área
	if detection_zone.jogador_na_area():
		regen_timer.stop()
		is_regenerating = false
		
	if !is_regenerating and regen_timer.is_stopped() and value_current < value_max and !detection_zone.jogador_na_area():
		regen_timer.start()
		is_regenerating = true


func _on_regen_timer_timeout():
	if !is_regenerating:
		is_regenerating = true
