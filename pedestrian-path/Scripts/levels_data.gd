class_name LevelsDatabase

static var LEVEL_SCENES : Array[String] = []
static var levelNodes : Array[Node2D]

static var xLevelOffset : float = 0.0
static var yLevelOffset : float = 0.0

static var levelsCount : int = 0
static var maxHeight : int = 0

static var xLevelCenter : float = 0.0
static var yLevelCenter : float = 0.0

static var lvlSwitchInProgress : bool = false

static var currLevel : int = 0:
	set(value):
		currLevel = value
		#breakpoint # Stops execution live on change

static var prevLevel : int = 0

static func _load_level_scenes() -> void:
	#LEVEL_SCENES.clear()
	#var dir := DirAccess.open("res://Levels")
	#if dir == null:
		#push_error("LevelsDatabase: Could not open res://Levels directory.")
		#return
#
	#var level_regex := RegEx.new()
	#level_regex.compile("^level_(\\d{2})\\.tscn$")
#
	#dir.list_dir_begin()
	#var file_name := dir.get_next()
	#while file_name != "":
		#if not dir.current_is_dir() and level_regex.search(file_name):
			#LEVEL_SCENES.append("res://Levels/%s" % file_name)
		#file_name = dir.get_next()
	#dir.list_dir_end()
#
	#LEVEL_SCENES.sort()
	#print(LEVEL_SCENES)

	LEVEL_SCENES.clear()
	var levelDir : DirAccess = DirAccess.open("res://Levels")
	if levelDir == null:
		push_error("LevelsDatabase: Could not open res://Levels directory.")
		return

	levelDir.list_dir_begin()
	var fileName : String = levelDir.get_next()
	while !fileName.is_empty():
		if not levelDir.current_is_dir():
			# In the editor, files end in .tscn
			# In an exported build, they end in .tscn.remap
			if fileName.begins_with("level_") and (fileName.ends_with(".tscn") or fileName.ends_with(".tscn.remap")):
				# Strip the .remap suffix so ResourceLoader can find the virtual asset
				var cleanName : String = fileName.replace(".remap", "")
				var full_path :String = "res://Levels/%s" % cleanName
				
				# Verify it actually loads via ResourceLoader before adding it
				if ResourceLoader.exists(full_path):
					# Prevent duplicates if both .tscn and .remap are spotted
					if not LEVEL_SCENES.has(full_path):
						LEVEL_SCENES.append(full_path)
						
		fileName = levelDir.get_next()
	levelDir.list_dir_end()

	LEVEL_SCENES.sort()
	print(LEVEL_SCENES)

static func _set_values() -> void:
	_load_level_scenes()
	CardsHelper._set_values()

	xLevelCenter = 0.0
	yLevelCenter = 0.0

	xLevelOffset = 3000.0
	yLevelOffset = 2000.0
	
	lvlSwitchInProgress = false

	if SaveLoadHelper.fileExist:
		currLevel = SaveLoadHelper.save_data.get("game", 1).get("level", 1).get("current", 1) - 1
		prevLevel = currLevel
	else:
		#Value starts at 0 not 1 for the array!
		currLevel = 0
		prevLevel = 0

	levelsCount = LEVEL_SCENES.size()
	maxHeight = 10
	print("All Levels Loaded!")

static func _level_switcher(newLevelNum : int = -1) -> void:
	if LevelsDatabase.currLevel > LevelsDatabase.levelsCount:
		GameComplete.initialHide = false
		return

	lvlSwitchInProgress = true

	print("---------------")
	print("Level Switched to: ", newLevelNum)

	if newLevelNum < 0:
		#Normal internal function of level switching incrementally.
		prevLevel = LevelsDatabase.currLevel
		LevelsDatabase.currLevel += 1
	else:
		#Setting level forcibly to switch version.
		prevLevel = LevelsDatabase.currLevel
		LevelsDatabase.currLevel = newLevelNum
	print("Level Switcher Func - Current Level:", LevelsDatabase.currLevel)
	InputsData.begin_delay = true
	InputsData._reset_values()
	CameraHelper._reset_values_sp()
	CardsHelper._reset_values()

	if LevelsDatabase.currLevel >= LevelsDatabase.levelsCount:
		#print("Game Complete")
		return

	for k in LevelsDatabase.levelsCount:
		LevelsDatabase.levelNodes[k].global_position.x = 0.0
		LevelsDatabase.levelNodes[k].global_position.y = 0.0
		LevelsDatabase.levelNodes[k].z_index = -2000
		#LevelsDatabase.levelNodes[k].global_position.y -= yLevelOffset
		#if (k != 0) && ((k % LevelsDatabase.maxHeight) == 0):
			#LevelsDatabase.levelNodes[k].global_position.x -= xLevelOffset
	LevelsDatabase.levelNodes[LevelsDatabase.currLevel].z_index = 0

	for k in PlayersHelper.playerNodes.size():
		PlayersHelper.clear_ghosts_for_player(k)
		PlayersHelper.playerNodes[k].get_child(0).position = Vector2(0.0, 0.0)
		PlayersHelper.playerNodes[k].global_position = LevelsDatabase.levelNodes[LevelsDatabase.currLevel].get_child(0).global_position
		PlayersHelper.playerNodes[k].get_child(0)._start_new_run()
		PlayersHelper.playerNodes[k].get_child(0).is_moving_forward = false
		PlayersHelper.playerNodes[k].get_child(0).is_moving_backward = false
		PlayersHelper.playerNodes[k].get_child(0).is_jumping_upward = false
		PlayersHelper.playerNodes[k].get_child(0).is_jumping_forward = false
		PlayersHelper.playerNodes[k].get_child(0).is_speeding_up = false
		PlayersHelper.playerNodes[k].get_child(0).is_speeding_down = false
		PlayersHelper.playerNodes[k].get_child(0).is_stopping = false
		PlayersHelper.playerNodes[k].get_child(0).long_press_triggered = false
		PlayersHelper.playerNodes[k].get_child(0).action_in_progress = false
		PlayersHelper.playerNodes[k].get_child(0).move_timer = 0.0
		PlayersHelper.playerNodes[k].get_child(0).lerpTVal = 0.0
		PlayersHelper.playerNodes[k].get_child(0).old_position = PlayersHelper.playerNodes[k].get_child(0).position
		PlayersHelper.playerNodes[k].get_child(0).new_position = PlayersHelper.playerNodes[k].get_child(0).position
		InputsData.move_speed = 0.0

	CardsHelper._level_switching_values()

	for k in LevelsDatabase.levelsCount:
		if k == LevelsDatabase.currLevel:
			continue
		LevelsDatabase.levelNodes[k].global_position.x = -9999.0
		LevelsDatabase.levelNodes[k].global_position.y = -9999.0

	#CamPos is second child of the level!
	#CameraHelper.camera_position = LevelsDatabase.levelNodes[LevelsDatabase.currLevel].get_child(1).global_position

	LevelsDatabase.levelNodes[LevelsDatabase.currLevel].get_child(1).set_deferred("monitoring", true)
	CountdownData.countdownVal = LevelsDatabase.levelNodes[LevelsDatabase.currLevel].get_child(4).countdownVal

	SaveLoadHelper.save_game()
	print("---------------")
