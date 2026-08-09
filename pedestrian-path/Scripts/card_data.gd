class_name CardsHelper

static var CARD_SCENE = preload("res://Scenes/card.tscn")
static var deckNodes : Array[Node2D]
static var handNodes : Array[Node2D]

static var cardLevelOpenInit : bool
static var cardLevelCloseInit : bool

static var cardTextures : Array[Texture2D]

static var deckSize : int = 0

static var xCardCenter : float = 0.0
static var yCardCenter : float = 0.0
static var xCardOffset : float = 0.0

static var xCardDeckCenter : float = 0.0
static var yCardDeckCenter : float = 0.0

static var xInf : float = 0.0
static var yInf : float = 0.0

static var handLimit : int = 0
static var handLimits : Array[Array] = []

static var usedPileUpdated : bool = false

static func _load_card_textures() -> void:
	cardTextures.clear()
	var cardDir : DirAccess = DirAccess.open("res://Textures")
	if cardDir == null:
		push_error("CardsHelper: Could not open res://Textures directory.")
		return

	#var cardTex_regex := RegEx.new()
	#cardTex_regex.compile("^Card_.*\\.png$")
#
	#dir.list_dir_begin()
	#var file_name := dir.get_next()
	#while file_name != "":
		#if not dir.current_is_dir() and cardTex_regex.search(file_name):
			#cardTextures.append(load("res://Textures/%s" % file_name))
		#file_name = dir.get_next()
	#dir.list_dir_end()

	cardDir.list_dir_begin()
	var fileName : String = cardDir.get_next()
	while !fileName.is_empty():
		if not cardDir.current_is_dir():
			# In the editor, files end in .tscn
			# In an exported build, they end in .tscn.remap
			if fileName.begins_with("Card_") and (fileName.ends_with(".png") or fileName.ends_with(".png.import")):
				# Strip the .import suffix so ResourceLoader can find the virtual asset
				var cleanName : String = fileName.replace(".import", "")
				var full_path :String = "res://Textures/%s" % cleanName
				
				# Verify it actually loads via ResourceLoader before adding it
				if ResourceLoader.exists(full_path):
					var tex : Texture2D = load(full_path)
					if not cardTextures.has(tex):
						cardTextures.append(tex)
						
		fileName = cardDir.get_next()
	cardDir.list_dir_end()


	cardTextures.sort()
	print(cardTextures)
	print("All Card Textures Loaded")

static func _set_values() -> void:
	deckSize = 10
	_more_setters()

static func _reset_values() -> void:
	deckSize = SaveLoadHelper.save_data.get("game", 1).get("cards", 1).get("deck_size", 1)
	print("Cards Deck Size: ", deckSize)

	handLimit = SaveLoadHelper.save_data.get("game", 1).get("cards", 1).get("hand_limit", 1)
	print("Current Hand Limit: ", handLimit)

	handLimits = SaveLoadHelper.save_data.get("game", 1).get("cards", 1).get("hand_limits", 1)
	print("Hand Limits Array: ", handLimits)

static func _level_switching_values() -> void:
	handLimit = LevelsDatabase.levelNodes[LevelsDatabase.currLevel].get_child(4).handValues.size()
	cardLevelCloseInit = false

static func _set_hand_limits_arr() -> void:
	#Hand limits appended for each level!
	#for k in LevelsDatabase.levelsCount:
		#handLimits.append(LevelsDatabase.levelNodes[k].get_child(4).handValues)
	#handLimit = LevelsDatabase.levelNodes[0].get_child(4).handValues.size()
	pass

static func _more_setters() -> void:
	cardLevelOpenInit = false
	cardLevelCloseInit = true
	xCardCenter = 200.0
	yCardCenter = 600.0
	xCardOffset = 100.0
	xCardDeckCenter = 1150.0
	yCardDeckCenter = 600.0
	xInf = -9999.0
	yInf = -9999.0
	usedPileUpdated = false

	_load_card_textures()
