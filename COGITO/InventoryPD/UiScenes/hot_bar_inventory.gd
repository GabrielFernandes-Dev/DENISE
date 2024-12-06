extends PanelContainer

signal ability_used(index: int)

const Slot = preload("res://COGITO/InventoryPD/UiScenes/Slot.tscn")
@onready var h_box_container = $MarginContainer/VBoxContainer/TopRow

@export_range(1, 8) var hotbar_slot_amount: int = 4
var assigned_indexes = []

var player: Node

func _unhandled_input(event):
    if not visible:
        return
        
    if event.is_action_released("quickslot_1"):
        ability_used.emit(0)
    elif event.is_action_released("quickslot_2"):
        ability_used.emit(1)
    elif event.is_action_released("quickslot_3"):
        ability_used.emit(2)
    elif event.is_action_released("quickslot_4"):
        ability_used.emit(3)

func initialize(player_node: Node) -> void:
    player = player_node
    populate_hotbar()
    ability_used.connect(player.use_ability)

func populate_hotbar() -> void:
    for child in h_box_container.get_children():
        child.queue_free()
    
    for i in range(hotbar_slot_amount):
        var slot = Slot.instantiate()
        h_box_container.add_child(slot)
        
        if player and i < player.abilities.size():
            slot.set_ability_data(player.abilities[i], i)
