extends Node2D

var veichleInitialX : float = 1000;
var veichleInitialY : float = 480;
var veichleOffsetY : float = 10;

var pedestrianInitialX : float = 1000;
var pedestrianInitialY : float = 180;
var pedestrianOffsetY : float = 10;

var initializationAccumulationTime : float = 0.0
var initializationAccumulationTimer : float = 10.0
var initializationCommplete : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveLoadHelper._file_checker()

	if SaveLoadHelper.fileExist:
		SaveLoadHelper.load_game()

	#If a file exists then use the loaded information otherwise internally it sets to 1.
	PlayersHelper._set_player_info()

	var ghost_container := Node2D.new()
	ghost_container.name = "Ghosts"
	add_child(ghost_container)
	PlayersHelper._set_ghost_container(ghost_container)

	LevelsDatabase._set_values()

	_spawn_levels()
	_spawn_players()
	_spawnVeichle()
	_spawnPed()
	#_spawn_cards()

	for k in LevelsDatabase.levelsCount:
		if k == 0:
			continue
		LevelsDatabase.levelNodes[k].global_position.x = -9999.0
		LevelsDatabase.levelNodes[k].global_position.y = -9999.0

	LevelsDatabase.levelNodes[0].z_index = 0
	CardsHelper._set_hand_limits_arr()

	#CamPos is second child of the level!
	#CameraHelper.camera_position = LevelsDatabase.levelNodes[LevelsDatabase.currLevel].get_child(1).global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if initializationCommplete == false:
		initializationAccumulationTime += _delta
		if initializationAccumulationTime > initializationAccumulationTimer:
			initializationAccumulationTime = 0.0
			initializationCommplete = true
		return
	_spawnVeichle()
	_spawnPed()
	initializationCommplete = false

func _spawnVeichle() -> void:
	PlayersHelper.vehicleCount = 4
	for count in PlayersHelper.vehicleCount:
		var instance = PlayersHelper.VEHICLE_SCENE.instantiate()
		var randVal = randf_range(-10, 10)
		instance.global_position = Vector2(veichleInitialX, veichleInitialY + (veichleOffsetY * randVal))
		add_child(instance)
		PlayersHelper.vehicleNodes.append(instance)		

func _spawnPed() -> void:
	PlayersHelper.pedestrianCount = 4
	for count in PlayersHelper.pedestrianCount:
		var instance = PlayersHelper.PEDESTRIAN_SCENE.instantiate()
		var randVal = randf_range(-10, 10)
		instance.global_position = Vector2(pedestrianInitialX, pedestrianInitialY + (pedestrianOffsetY * randVal))
		add_child(instance)
		PlayersHelper.pedestrianNodes.append(instance)

func _spawn_levels() -> void:
	#var j : int = 0
	for k in LevelsDatabase.levelsCount:
		print(LevelsDatabase.LEVEL_SCENES[k])
		var level_instance = load(LevelsDatabase.LEVEL_SCENES[k]).instantiate()
		print(level_instance)
		#level_instance.global_position.x = LevelsDatabase.xLevelCenter + (j * LevelsDatabase.xLevelOffset)
		#level_instance.global_position.y = LevelsDatabase.yLevelCenter + ((k % LevelsDatabase.maxHeight) * LevelsDatabase.yLevelOffset)
		level_instance.global_position.x = 0.0
		level_instance.global_position.y = 0.0
		level_instance.z_index = -2000
		add_child(level_instance)
		LevelsDatabase.levelNodes.append(level_instance)

		#if (k != 0) && ((k % LevelsDatabase.maxHeight) == 0):
			#j += 1

func _spawn_players() -> void:
	for k in PlayersHelper.playersCount:
		var player_instance = PlayersHelper.PLAYER_SCENE.instantiate()
		player_instance.global_position = LevelsDatabase.levelNodes[LevelsDatabase.currLevel].get_child(0).global_position
		player_instance.name = "Player_" + str(k)
		player_instance.get_child(0).player_id = k
		var playerSpr = player_instance.get_child(0).get_child(1) as Sprite2D
		playerSpr.texture = load("res://Textures/Player" + str(k) + ".png")
		add_child(player_instance)
		PlayersHelper.playerNodes.append(player_instance)

func _spawn_cards() -> void:
	CardsHelper.handNodes.clear()
	for k in CardsHelper.deckSize:
		var card_instance = CardsHelper.CARD_SCENE.instantiate()
		card_instance.global_position.x = CardsHelper.xCardDeckCenter
		card_instance.global_position.y = CardsHelper.yCardDeckCenter
		card_instance.name = "Card_" + str(k)
		card_instance.get_child(0).cardTypeVal = CardType.CARD_TYPE_ENUM.BACKSIDE
		#Making sure the cards are layered one above the other!
		card_instance.get_child(0).zIndex += 10
		card_instance.get_child(0).cardDeckPosition = Vector2(CardsHelper.xCardDeckCenter, CardsHelper.yCardDeckCenter)
		card_instance.get_child(0).cardHandPosition = Vector2(CardsHelper.xCardDeckCenter, CardsHelper.yCardDeckCenter)
		add_child(card_instance)
		CardsHelper.deckNodes.append(card_instance)
