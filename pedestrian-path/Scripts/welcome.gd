extends TextEdit

@export var initialDelayAccumulation : float = 0.0
@export var initialDelayMax : float = 0.0
@export var initialHide : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialDelayAccumulation = 0.0
	initialDelayMax = 10.0
	wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if initialHide == false:
		initialDelayAccumulation += _delta
		if initialDelayAccumulation > initialDelayMax:
			initialDelayAccumulation = 0.0
			initialHide = true
			hide()
		return


func _input(event: InputEvent):
	# Check if a mouse button is clicked while the node has focus
	if has_focus() and event is InputEventMouseButton and event.pressed:
		# If the click position is outside the node's rectangle
		if not get_global_rect().has_point(event.position):
			release_focus()
