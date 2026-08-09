extends TextEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	editable = false
	#text = "Players Count: " + str(PlayersHelper.playersCount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#var regex = RegEx.new()
	## Regex pattern matches an optional negative sign followed by digits and a decimal point
	#regex.compile("-?\\d+\\.?\\d+") 
#
	#var result = regex.search(text)
	#var first_int : int = 0
	#if result:
		#first_int = result.get_string().to_int()
#
	#if InputsData.begin_delay:
		#text = "Num Players: " + str(PlayersHelper.numPlayers)
	#else:
		#PlayersHelper.numPlayers = first_int
	text = "Players Count: " + str(PlayersHelper.playersCount)

func _input(event: InputEvent):
	# Check if a mouse button is clicked while the node has focus
	if has_focus() and event is InputEventMouseButton and event.pressed:
		# If the click position is outside the node's rectangle
		if not get_global_rect().has_point(event.position):
			release_focus()
