extends SubViewport

func _ready():
    # Garante que o viewport pode receber input
    handle_input_locally = true
    gui_disable_input = false
    
