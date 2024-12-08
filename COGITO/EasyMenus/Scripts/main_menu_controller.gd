extends Control

signal start_game_pressed

@export var first_focus_button: Button
@onready var game_menu: MarginContainer = $ContentMain/GameMenu
@onready var options_tab_menu: OptionsTabMenu = $ContentMain/OptionsTabMenu
@onready var options_button: CogitoUiButton = $ContentMain/GameMenu/HBoxContainer/OptionsButton

#region UI AUDIO
@export var sound_hover : AudioStream
@export var sound_click : AudioStream
var playback : AudioStreamPlaybackPolyphonic

func _ready():
	# Configuração básica
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Configura todos os controles do menu
	_setup_menu_controls()

	# Debug das configurações
	_print_debug_info()

func _setup_menu_controls():
	# Configura o GameMenu
	game_menu.mouse_filter = Control.MOUSE_FILTER_STOP

	# Configura o HboxContainer
	var hbox = $ContentMain/GameMenu/HBoxContainer
	hbox.mouse_filter = Control.MOUSE_FILTER_STOP

	# Configura todos os botões
	for button in _get_all_buttons():
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.focus_mode = Control.FOCUS_ALL
		
		# Conecta sinais para debug
		button.mouse_entered.connect(func(): print("Mouse entered: ", button.name))
		button.gui_input.connect(func(event): _on_button_input(event, button))
		print("Configurado botão: ", button.name)

func _get_all_buttons() -> Array:
	var buttons = []
	_find_buttons(self, buttons)
	return buttons

func _find_buttons(node: Node, buttons: Array):
	if node is Button:
		buttons.append(node)
	for child in node.get_children():
		_find_buttons(child, buttons)

func _print_debug_info():
	print("\n=== Menu Configuration Debug ===")
	print("Menu mouse_filter: ", mouse_filter)
	print("GameMenu mouse_filter: ", game_menu.mouse_filter)
	print("HBoxContainer mouse_filter: ", $ContentMain/GameMenu/HBoxContainer.mouse_filter)

	print("\n=== Button Configurations ===")
	for button in _get_all_buttons():
		print("Button: ", button.name)
		print("- mouse_filter: ", button.mouse_filter)
		print("- focus_mode: ", button.focus_mode)
		print("- global_position: ", button.global_position)
		print("- size: ", button.size)

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		print("\n=== Mouse Click Debug ===")
		print("Click position: ", event.position)

		# Verifica qual controle está sob o mouse
		var control_under_mouse = _get_control_at_position(event.position)
		print("Control under mouse: ", control_under_mouse.name if control_under_mouse else "None")

func _get_control_at_position(position: Vector2) -> Control:
	return _find_control_at_position(self, position)	

func _find_control_at_position(node: Node, position: Vector2) -> Control:
	if node is Control:
		var control = node as Control
		if control.get_global_rect().has_point(position):
            # Procura nos filhos primeiro para encontrar o controle mais específico
			for child in node.get_children():
				var result = _find_control_at_position(child, position)
				if result:
					return result
			return control
	else:
		for child in node.get_children():
			var result = _find_control_at_position(child, position)
			if result:
				return result
	return null

func _on_button_input(event: InputEvent, button: Button):
	if event is InputEventMouseButton and event.pressed:
		print("Button ", button.name, " received click!")
		if button == options_button:
			print("Options button clicked!")
			open_options_menu()
        # Adicione outros botões conforme necessário

func _enter_tree() -> void:
	# Create an audio player
	var player = AudioStreamPlayer.new()
	add_child(player)

	# Create a polyphonic stream so we can play sounds directly from it
	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	player.stream = stream
	player.play()
	# Get the polyphonic playback stream to play sounds
	playback = player.get_stream_playback()

	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node:Node) -> void:
	if node is Button:
		# If the added node is a button we connect to its mouse_entered and pressed signals
		# and play a sound
		node.mouse_entered.connect(_play_hover)
		node.pressed.connect(_play_pressed)

func _play_hover() -> void:
	playback.play_stream(sound_hover, 0, 0, 1)

func _play_pressed() -> void:
	playback.play_stream(sound_click, 0, 0, 1)
#endregion

func quit():
	get_tree().quit()

# func _input(event):
# 	if (event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause")) and !game_menu.visible:
# 		accept_event()
# 		options_tab_menu.hide()
# 		game_menu.show()
# 		options_button.grab_focus.call_deferred()

func open_options_menu():
	print("clique funcionou")
	options_tab_menu.show()
	options_tab_menu.nodes_to_focus[0].grab_focus.call_deferred()
	game_menu.hide()

func _on_start_game_button_pressed():
	emit_signal("start_game_pressed")
