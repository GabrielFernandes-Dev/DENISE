class_name SlotPanel extends PanelContainer

@onready var texture_rect = $MarginContainer/TextureRect
@onready var cooldown_label = $ChargeLabel  # Reusando o ChargeLabel para cooldown
@onready var selection_panel = $Selected

@export var highlight_color : Color
@export var sound_highlight : AudioStream

var ability_data = null  # Referência para a habilidade atual
var slot_index : int = -1
var cooldown_overlay: ColorRect

signal slot_clicked(index: int, mouse_button: int)
signal slot_pressed(index: int, action: String)
signal highlight_slot(index: int, highlight: bool)

func _ready():
    # Configurar overlay de cooldown
    cooldown_overlay = ColorRect.new()
    cooldown_overlay.color = Color(0, 0, 0, 0.5)
    cooldown_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(cooldown_overlay)
    cooldown_overlay.hide()

func set_ability_data(ability: CogitoAbility, index: int) -> void:
    ability_data = ability
    slot_index = index
    
    if ability:
        # Configura o ícone da habilidade
        texture_rect.texture = ability.icon if ability.icon else null
        
        # Configura o label de cooldown
        if cooldown_label:
            cooldown_label.text = str(ability.cooldown_time) if ability.is_on_cooldown else ""
            cooldown_label.show()
            
        # Conecta o sinal de cooldown se necessário
        if !ability.is_connected("cooldown_changed", _on_cooldown_changed):
            ability.connect("cooldown_changed", _on_cooldown_changed)
    else:
        texture_rect.texture = null
        if cooldown_label:
            cooldown_label.hide()

func _on_cooldown_changed(is_on_cd: bool, time_left: float) -> void:
    if cooldown_label:
        if is_on_cd:
            cooldown_label.text = str(snapped(time_left, 0.1))
            cooldown_overlay.show()
            # Atualiza a altura do overlay baseado no tempo restante
            var progress = time_left / ability_data.cooldown_time
            cooldown_overlay.scale.y = progress
        else:
            cooldown_label.text = ""
            cooldown_overlay.hide()

func set_selection(is_selected : bool):
    selection_panel.visible = is_selected

func _on_gui_input(event):
    if event is InputEventMouseButton \
            and (event.button_index == MOUSE_BUTTON_LEFT \
            or event.button_index == MOUSE_BUTTON_RIGHT) \
            and event.is_pressed():
        slot_clicked.emit(slot_index, event.button_index)
    
    # Mantendo a interação com gamepad
    if event.is_action_pressed("ability_use"):
        slot_pressed.emit(slot_index, "ability_use")
        highlight_slot.emit(slot_index, true)

func _on_mouse_entered():
    grab_focus()

func _on_mouse_exited():
    release_focus()

func _on_hidden():
    release_focus()

func _on_focus_entered() -> void:
    Audio.play_sound(sound_highlight)
    highlight_slot.emit(slot_index, true)
    $Panel.show()

func _on_focus_exited() -> void:
    highlight_slot.emit(slot_index, false)
    $Panel.hide()

# Função para atualizar o visual do cooldown externamente se necessário
func update_cooldown_visual(progress: float) -> void:
    if cooldown_overlay:
        if progress <= 0:
            cooldown_overlay.hide()
        else:
            cooldown_overlay.show()
            cooldown_overlay.scale.y = progress
