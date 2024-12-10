extends TextEdit

var should_focus = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#insert_text("Hello there!", 0, 0)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("editor_toggle"):
		should_focus = !should_focus
		if should_focus == true:
			self.grab_focus()
		else:
			self.release_focus()
	pass
