extends TextEdit

var editor_focus = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("editor_toggle"):
		editor_focus = !editor_focus
		if editor_focus == true:
			self.grab_focus()
		else:
			self.release_focus()
	pass
