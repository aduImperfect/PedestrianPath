extends Sprite2D

@export var cardTypeVal : CardType.CARD_TYPE_ENUM
@export var zIndex : int
@export var cardDeckPosition : Vector2
@export var cardHandPosition : Vector2
@export var cardSpeed : float

@export var startLerp : float
@export var endLerp : float
@export var lerpVal : float
@export var lerped : bool
@export var revLerp : bool

@export var normal_state : bool
@export var highlighted_state : bool
@export var selected_state : bool

@export var selectedDelayAccumulation : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cardSpeed = 1.0
	startLerp = 0.0
	endLerp = 1.0
	lerpVal = 0.0
	lerped = false
	revLerp = false
	normal_state = true
	highlighted_state = false
	selected_state = false
	selectedDelayAccumulation = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if CardsHelper.cardTextures.size() != CardType.CARD_TYPE_ENUM.size():
		return

	texture = CardsHelper.cardTextures[int(cardTypeVal)]

	if normal_state:
		self_modulate = Color(1.0, 1.0, 1.0, 1.0)

	if highlighted_state:
		self_modulate = Color(2.0, 2.0, 0.0, 1.0)

	if selected_state:
		self_modulate = Color(2.0, 2.0, selectedDelayAccumulation, 1.0)

	z_index = zIndex

	if cardHandPosition.is_equal_approx(global_position):
		return

	if lerped == false:
		lerpVal += _delta * cardSpeed
		if lerpVal <= endLerp:
			if revLerp == false:
				global_position = lerp(cardDeckPosition, cardHandPosition, lerpVal)
			else:
				global_position = lerp(cardHandPosition, cardDeckPosition, lerpVal)
		else:
			#Get it ready for the reverse lerp!
			revLerp = !revLerp
			lerpVal = 0.0
			lerped = true
			if CardsHelper.usedPileUpdated:
				cardHandPosition = cardDeckPosition
				return
			if revLerp == false:
				cardHandPosition = cardDeckPosition
				CardsHelper.cardLevelOpenInit = false
