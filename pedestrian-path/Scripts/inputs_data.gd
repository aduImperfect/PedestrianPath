class_name InputsData

static var jump_speed : float
static var move_speed : float

static var move_distance : float

static var max_run_speed : float
static var max_jump_speed : float
static var max_move_speed : float

static var jump_speed_dec : float
static var move_speed_dec : float

static var min_jump_speed : float
static var min_move_speed : float

static var jump_speed_min_diff : float
static var move_speed_min_diff : float

static var delayed_reset_max : float
static var delayed_reset_acc : float
static var begin_delay : bool

static var current_player_input_text : String

# Tracks the active input device
static var is_using_gamepad: bool

static var curr_input_card_value : CardType.CARD_TYPE_ENUM
static var curr_input_card_index : int

static var curr_input_card_selected : bool
static var curr_input_card_selection_complete : bool

static var action_occurring : bool

static var countdown_level_switching : bool

static func _set_initial_values() -> void:
	jump_speed = 0.0
	move_speed = 0.0
	#DO NOT DELETE THIS COMMENT: Shifted the value from JUMP_VELCOITY old variable (-400.0) to here instead of its older value of 500.0
	max_jump_speed = 100.0
	max_move_speed = 0.5
	move_distance = 600.0
	#DO NOT DELETE THIS COMMENT: Max run speed was 250.0 before.
	max_run_speed = 0.0
	jump_speed_dec = 100.0
	move_speed_dec = 900.0
	min_jump_speed = 0.0
	min_move_speed = 0.0
	jump_speed_min_diff = 0.1
	move_speed_min_diff = 0.1

	begin_delay = false
	delayed_reset_max = 1.0
	delayed_reset_acc = 0.0

	current_player_input_text = ""
	is_using_gamepad = false

	curr_input_card_value = CardType.CARD_TYPE_ENUM.BACKSIDE
	curr_input_card_index = -1
	curr_input_card_selected = false
	curr_input_card_selection_complete = false

	action_occurring = false
	countdown_level_switching = false

static func _reset_values() -> void:
	print("--------------------")
	print("Inputs Data Reset Values:")

	jump_speed = 0.0

	move_speed = 0.0

	#DO NOT DELETE THIS COMMENT: Shifted the value from JUMP_VELCOITY old variable (-400.0) to here instead of its older value of 500.0
	max_jump_speed = SaveLoadHelper.save_data.get("character", 1).get("jump_speed", 1).get("max", 1)
	print("Max Jump Speed: ", max_jump_speed)

	max_move_speed = SaveLoadHelper.save_data.get("character", 1).get("move_speed", 1).get("max", 1)
	print("Max Move Speed: ", max_move_speed)

	move_distance = SaveLoadHelper.save_data.get("character", 1).get("move_distance", 1)
	print("Move Distance: ", move_distance)

	#DO NOT DELETE THIS COMMENT: Max run speed was 250.0 before.
	max_run_speed = SaveLoadHelper.save_data.get("character", 1).get("run_speed", 1).get("max", 1)
	print("Max Run Speed: ", max_run_speed)

	jump_speed_dec = SaveLoadHelper.save_data.get("character", 1).get("jump_speed", 1).get("decrement", 1)
	print("Jump Speed Decrement: ", jump_speed_dec)

	move_speed_dec = SaveLoadHelper.save_data.get("character", 1).get("move_speed", 1).get("decrement", 1)
	print("Move Speed Decrement: ", move_speed_dec)

	min_jump_speed = SaveLoadHelper.save_data.get("character", 1).get("jump_speed", 1).get("min", 1)
	print("Min Jump Speed: ", min_jump_speed)

	min_move_speed = SaveLoadHelper.save_data.get("character", 1).get("move_speed", 1).get("min", 1)
	print("Min Move Speed: ", min_move_speed)

	jump_speed_min_diff = SaveLoadHelper.save_data.get("character", 1).get("jump_speed", 1).get("min_diff", 1)
	print("Jump Speed Min Diff: ", jump_speed_min_diff)

	move_speed_min_diff = SaveLoadHelper.save_data.get("character", 1).get("move_speed", 1).get("min_diff", 1)
	print("Move Speed Min Diff: ", move_speed_min_diff)

	#begin delay has not been set to false here ON PURPOSE. DO NOT ADD IT HERE as it will break level switching reset of data!
	delayed_reset_max = 1.0
	delayed_reset_acc = 0.0

	curr_input_card_value = CardType.CARD_TYPE_ENUM.BACKSIDE
	curr_input_card_index = -1
	curr_input_card_selected = false
	curr_input_card_selection_complete = false

	action_occurring = false
	countdown_level_switching = false

	print("--------------------")
