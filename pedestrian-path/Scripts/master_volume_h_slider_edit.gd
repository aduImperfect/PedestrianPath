extends HSlider

var timerAccumulation : float = 0.0
var timerMax : float = 0.0
var timerReached : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timerAccumulation = 0.0
	timerMax = 0.5
	timerReached = false
	value = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if timerReached == false:
		timerAccumulation += _delta
		if timerAccumulation > timerMax:
			timerAccumulation = 0.0
			value = AudioDatabase.audioMasterVolume
			timerReached = true
		return

	if InputsData.begin_delay:
		timerReached = false
	else:
		AudioDatabase.audioMasterVolume = value

func _input(event: InputEvent):
	# Check if a mouse button is clicked while the node has focus
	if has_focus() and event is InputEventMouseButton and event.pressed:
		# If the click position is outside the node's rectangle
		if not get_global_rect().has_point(event.position):
			release_focus()
