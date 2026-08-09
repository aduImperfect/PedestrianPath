class_name SaveLoadHelper

# Always use "user://" because "res://" is read-only in exported games
const DATA_DIR = "user://Data"
const SAVE_PATH = "user://Data/save_game.json"
const SAVE_PATH_WITHOUT_TYPE = "user://Data/save_game"
const TYPE = ".json"

static var fileExist : bool = false

static var save_data : Dictionary = {}

static var json_string_load : String
static var json_string_save : String

static func _file_checker() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		fileExist = false
	else:
		fileExist = true

# 1. SAVE FUNCTION
static func save_game() -> void:
	print("--------------------")

	save_data = {
		"game": {
			"level": {
				#It needs to always force set to 1 (the starting level) instead of the current level + 1 for making sure the default stays at default!
				#"current": LevelsDatabase.currLevel + 1,
				"current": 1,
			},
			"player": {
				"count": PlayersHelper.playersCount,
			},
			"camera": {
				"smoothing_speed": CameraHelper.smoothing_speed
			},
			"audio": {
				"volume": {
					"master": AudioDatabase.audioMasterVolume
				}
			},
			"cards": {
				"deck_size": CardsHelper.deckSize,
				"hand_limit": CardsHelper.handLimit,
				"hand_limits" : CardsHelper.handLimits,
			},
		},
		"character": {
			"jump_speed": {
				"max": InputsData.max_jump_speed,
				"min": InputsData.min_jump_speed,
				"decrement": InputsData.jump_speed_dec,
				"min_diff": InputsData.jump_speed_min_diff
			},
			"move_speed": {
				"max": InputsData.max_move_speed,
				"min": InputsData.min_move_speed,
				"decrement": InputsData.move_speed_dec,
				"min_diff": InputsData.move_speed_min_diff
			},
			"run_speed": {
				"max": InputsData.max_run_speed
			},
			"move_distance": InputsData.move_distance,
		},
	}

	print("SAVE DATA VALUE ON SAVE: ", save_data)

	# Check if the folder already exists
	if not DirAccess.dir_exists_absolute(DATA_DIR):
		var error = DirAccess.make_dir_recursive_absolute(DATA_DIR)
		if error == OK:
			print("Folder created successfully!")
		else:
			print("Failed to create folder. Error code: ", error)
	else:
		print("Folder: " + str(DATA_DIR) + " already exists!")

	# Open the file for writing
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file:
		# Convert the Dictionary to a JSON string
		json_string_save = JSON.stringify(save_data)
		# Write it to the file
		file.store_line(json_string_save)
		file.close()

		print("JSON STRING SAVE: ", json_string_save)

		print("Game Saved!")
		print("JSON file successfully created/updated at: ", ProjectSettings.globalize_path(SAVE_PATH))
		fileExist = true
	else:
		print("Failed to create file. Error code: ", FileAccess.get_open_error())
		fileExist = false

	#Backup save data into a file with current datetime.
	var datetime_dict = Time.get_datetime_dict_from_system()

	var additiveString : String = "_backup_" + str(datetime_dict.year) + "_" + str(datetime_dict.month) + "_" + str(datetime_dict.day) + "_" + str(datetime_dict.hour) + "_" + str(datetime_dict.minute) + "_" + str(datetime_dict.second)

	var BACKUP_SAVE_PATH : String = SAVE_PATH_WITHOUT_TYPE + additiveString + TYPE

	# Open a copy file for writing
	var backupSaveFile = FileAccess.open(BACKUP_SAVE_PATH, FileAccess.WRITE)

	if file:
		# Convert the Dictionary to a JSON string
		var temp_json_string_save = JSON.stringify(save_data)
		# Write it to the file
		backupSaveFile.store_line(temp_json_string_save)
		backupSaveFile.close()
		print("Copy File Saved!")
	else:
		print("Failed to create copy file. Error code: ", FileAccess.get_open_error())

	print("--------------------")
	#DO NOT REMOVE: Forcing the check for level switch to end here!
	LevelsDatabase.lvlSwitchInProgress = false


# 2. LOAD FUNCTION
static func load_game() -> void:
	print("--------------------")

	# Check if the file exists before reading
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		print("Failed to open file to load!")
		fileExist = false
		return

	# Open the file for reading
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		json_string_load = file.get_as_text()
		file.close()
		print("JSON STRING LOAD: ", json_string_load)

		# Parse the string back into a usable Godot Dictionary
		save_data = JSON.parse_string(json_string_load)
		print("SAVE DATA VALUE ON LOAD: ", save_data)

		# Check if parsing was successful
		if save_data == null:
			print("Error parsing JSON string.")
			return

		print("Game Loaded!")
		fileExist = true
	else:
		fileExist = false

	print("--------------------")
