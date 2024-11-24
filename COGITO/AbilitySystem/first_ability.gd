class_name FirstAbility
extends CogitoAbility

var max_range: float = 10.0 
var memory_cost: float = 256.0

func _init():
    ability_name = "First Ability"
    cooldown_time = 0.5

func use(player: Node) -> void:
    if is_on_cooldown:
        print("Habilidade em cooldown!")
        return
    
    if player.is_aiming_at_virus:
        var target = player.interaction_raycast.get_collider()
        var hit_point = player.interaction_raycast.get_collision_point()
        var distance = player.global_position.distance_to(hit_point)
        
        if distance <= max_range:
            print("Virus atingido!")

            player.memory_attribute.subtract(memory_cost)
        
            if not player.memory_attribute.attribute_changed.is_connected(_on_memory_changed):
                player.memory_attribute.attribute_changed.connect(_on_memory_changed)

            start_cooldown(player)
        else:
            print("Virus está além do alcance máximo de ", max_range, " unidades!")
    else:
        print("Precisa mirar em um virus para usar esta habilidade!")

func _on_memory_changed(attribute_name: String, value_current: float, value_max: float, has_increased: bool) -> void:
    if not has_increased:
        print("Memória consumida! Valor atual: ", value_current, "/", value_max)
