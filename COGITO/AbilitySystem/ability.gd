class_name CogitoAbility
extends Resource

signal cooldown_changed(is_on_cd: bool, time_left: float)

@export var ability_name: String = "Ability"
@export var cooldown_time: float = 1.0
@export var icon: Texture2D

var is_on_cooldown: bool = false
var cooldown_timer: Timer

# Método virtual para ser sobrescrito pelas habilidades específicas
func use(_player: Node) -> void:
    pass

func start_cooldown(player: Node) -> void:
    if !cooldown_timer:
        cooldown_timer = Timer.new()
        player.add_child(cooldown_timer)
        cooldown_timer.one_shot = true
        cooldown_timer.timeout.connect(_on_cooldown_finished)
    
    is_on_cooldown = true
    cooldown_timer.start(cooldown_time)
    
    # Emite o sinal inicial do cooldown
    cooldown_changed.emit(true, cooldown_time)
    
    # Configura o processo para atualizar o tempo restante
    player.process_mode = Node.PROCESS_MODE_ALWAYS
    player.process_priority = 1
    player.set_process(true)

func _process(_delta):
    if is_on_cooldown:
        cooldown_changed.emit(true, cooldown_timer.time_left)

func _on_cooldown_finished() -> void:
    is_on_cooldown = false
    cooldown_changed.emit(false, 0.0)
