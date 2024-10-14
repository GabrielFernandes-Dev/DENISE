@icon("res://COGITO/Assets/Graphics/Editor/Icon_CogitoSwitch.svg")
class_name CogitoSwitch
extends Node3D

signal object_state_updated(interaction_text: String) #used to display correct interaction prompts
signal switched(is_on: bool)
signal damage_received(damage_value:float)

#region Variables

## Sets if object starts as on or off.
@export var is_on : bool = false
## Toggle if switchable can be interacted with repeatedly or not.
@export var allows_repeated_interaction : bool = true
## Hint that displays after this has been used.
@export var has_been_used_hint : String
@export var interaction_text_when_on : String = "Switch off"
@export var interaction_text_when_off : String = "Switch on"
## Sound that plays when switched.
@export var switch_sound : AudioStream
## Check this if player needs to have an item in the inventory to switch.
@export var needs_item_to_operate : bool
## The item that the player needs to have in their inventory.
@export var required_item : InventoryItemPD
## Hint that gets displayed if the switch requires an item that the player currently doesn't have.
@export var item_hint : String
## Nodes that will become visible when switch is ON. These will hide again when switch is OFF.
@export var nodes_to_show_when_on : Array[Node]
## Nodes that will become hidden when switch is ON. These will show again when switch is OFF.
@export var nodes_to_hide_when_on : Array[Node]
## Nodes that will have their interact function called when this switch is used.
@export var objects_call_interact : Array[NodePath]
@export var objects_call_delay : float = 0.0

var interaction_text : String 
var player_interaction_component : PlayerInteractionComponent
var interaction_nodes : Array[Node]
var cogito_properties : CogitoProperties = null

@onready var audio_stream_player_3d = $AudioStreamPlayer3D

#endregion


func _ready():
	self.add_to_group("interactable")
	add_to_group("save_object_state")
	interaction_nodes = find_children("","InteractionComponent",true) #Grabs all attached interaction components
	
	audio_stream_player_3d.stream = switch_sound
	
	if is_on:
		switch_on()
	else:
		switch_off()


func interact(_player_interaction_component):
	player_interaction_component = _player_interaction_component
	if !allows_repeated_interaction and is_on:
		player_interaction_component.send_hint(null, has_been_used_hint)
		return
	if needs_item_to_operate:
		if check_for_item() == true:
			switch()
	else:
		switch()


func switch():
	audio_stream_player_3d.play()
	
	if !is_on:
		switch_on()
	else:
		switch_off()
	
	if !objects_call_interact:
		return
	for nodepath in objects_call_interact:
		await get_tree().create_timer(objects_call_delay).timeout
		if nodepath != null:
			var object = get_node(nodepath)
			object.interact(player_interaction_component)


func switch_on():
	for node in nodes_to_show_when_on:
		node.show()
		
	for node in nodes_to_hide_when_on:
		node.hide()
			
	is_on = true
	interaction_text = interaction_text_when_on
	object_state_updated.emit(interaction_text)
	switched.emit(is_on)


func switch_off():
	for node in nodes_to_show_when_on:
		node.hide()
		
	for node in nodes_to_hide_when_on:
		node.show()
	
	is_on = false
	interaction_text = interaction_text_when_off
	object_state_updated.emit(interaction_text)
	switched.emit(is_on)


func check_for_item() -> bool:
	var inventory = player_interaction_component.get_parent().inventory_data
	for slot_data in inventory.inventory_slots:
		if slot_data != null and slot_data.inventory_item == required_item:
			player_interaction_component.send_hint(null, required_item.name + " used.") # Sends a hint with the key item name.
			if slot_data.inventory_item.discard_after_use:
				inventory.remove_slot_data(slot_data)
			return true
	
	if item_hint != "":
		player_interaction_component.send_hint(null,item_hint) # Sends the key hint with the default hint icon.
	return false


func set_state():
	if is_on:
		for node in nodes_to_show_when_on:
			node.show()
		
		for node in nodes_to_hide_when_on:
			node.hide()
			
		interaction_text = interaction_text_when_on
	else:
		for node in nodes_to_show_when_on:
			node.hide()
		
		for node in nodes_to_hide_when_on:
			node.show()
			
		interaction_text = interaction_text_when_off
	
	object_state_updated.emit(interaction_text)


func save():
	var state_dict = {
		"node_path" : self.get_path(),
		"is_on" : is_on,
		"pos_x" : position.x,
		"pos_y" : position.y,
		"pos_z" : position.z,
		"rot_x" : rotation.x,
		"rot_y" : rotation.y,
		"rot_z" : rotation.z,
		
	}
	return state_dict
