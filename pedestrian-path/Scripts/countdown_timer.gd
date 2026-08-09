extends TextEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	editable = false
	CountdownData._initial_values()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var countdownLife : String = ""
	for k in CountdownData.countdownVal:
		countdownLife += "♥️"
	text = "⏳ ⌛ ⏰: " + countdownLife
	#wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY

func _input(event: InputEvent):
	# Check if a mouse button is clicked while the node has focus
	if has_focus() and event is InputEventMouseButton and event.pressed:
		# If the click position is outside the node's rectangle
		if not get_global_rect().has_point(event.position):
			release_focus()
