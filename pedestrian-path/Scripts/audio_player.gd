extends AudioStreamPlayer2D

#@export var audStyle : AudioDatabase.AudioStyle

@export var initialdelayAccumulation : float = 0.0
@export var initialdelayMax : float = 0.0
@export var initialized : bool = false

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	initialdelayAccumulation = 0.0
	initialdelayMax = 1.0
	initialized = false
	#stream = load(AudioDatabase.audioStreamStrs[audStyle])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if initialized == false:
		initialdelayAccumulation += _delta
		if initialdelayAccumulation > initialdelayMax:
			initialdelayAccumulation = 0.0
			initialized = true
		return
