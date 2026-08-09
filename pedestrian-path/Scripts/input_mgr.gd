extends CharacterBody2D

class_name InputMgr

@export var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var is_moving_forward : bool = false
@export var is_moving_backward : bool = false
@export var is_jumping_upward : bool = false
@export var is_jumping_forward : bool = false
@export var is_speeding_up : bool = false
@export var is_speeding_down : bool = false
@export var is_stopping : bool = false
@export var action_in_progress : bool = false

@export var grounded : bool = true
@export var is_running : bool = true

@export var text_edit_input : bool = false

# Export this variable to change it in the Inspector for each player node
@export var player_id: int = 0

@export var move_down_action: String
@export var move_up_action: String

@export var old_position : Vector2
@export var new_position : Vector2

# Time in seconds required to trigger a long press
@export var hold_duration: float = 1.2
var hold_timer: float = 0.0
var is_holding: bool = false
var long_press_triggered: bool = false

@export var move_duration : float = 2.0
var move_timer : float = 0.0

@export var lerpStart : float = 0.0
@export var lerpEnd : float = 0.0
@export var lerpTVal : float = 0.0

@export var wallHit : bool = false
@export var wallBounce : float = 500.0
@export var wallHitDuration : float = 0.0
@export var wallHitTimer : float = 0.0

# --- Ghost recording ---
var ghost_frames : PackedVector2Array = PackedVector2Array()
var run_start_global : Vector2 = Vector2.ZERO

@export var initializationAccumulationTime : float = 0.0
@export var initializationAccumulationTimer : float = 0.0
@export var initializationCommplete : bool = false

@export var moveDir : float = 0.0

var moveMaxPos : float = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initializationAccumulationTime = 0.0
	initializationAccumulationTimer = 0.25
	initializationCommplete = false
	move_duration = 2.0
	old_position = position
	new_position = position
	lerpStart = 0.0
	lerpEnd = 1.0
	lerpTVal = 0.0
	wallHit = false
	wallBounce = 100.0
	wallHitDuration = 0.0
	wallHitTimer = 0.5

func _initialize() -> void:
	#If first time consideration of initialization from code needs to be given priority!
	#Lazy check only during first player initialization starting as the InputsData are common static values currently!
	if player_id == 0:
		if SaveLoadHelper.fileExist:
			InputsData._reset_values()
		else:
			InputsData._set_initial_values()
		#BELOW PORTION NEEDS TO BE SET IN ITS OWN CAMERA MGR FUNCTION!
		#FORCED CURRENTLY INTO SINGLE PLAYER MODE FOR CAMERA!
		#Being set here to make sure it gets the proper UI update!
		if SaveLoadHelper.fileExist:
			CameraHelper._reset_values_sp()
		else:
			CameraHelper._set_initial_camera_values_sp()

	is_moving_forward = false
	is_moving_backward = false
	is_jumping_upward = false
	is_jumping_forward = false
	is_speeding_up = false
	is_speeding_down = false
	is_stopping = false

	grounded = true

	move_down_action = "ui_down_p" + str(player_id)
	move_up_action = "ui_up_p" + str(player_id)


	_add_input_actions_for_this_player()
	_start_new_run()

	#Lazy check only during last player initialization finishing as the InputsData are common static values currently!
	if player_id == (PlayersHelper.playersCount - 1):
		initializationCommplete = true
		SaveLoadHelper.save_game()
		if AudioDatabase.audio_styles_list_sttc.size() != 0:
			(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[0]].get_child(0) as AudioStreamPlayer2D).play()

	#CountdownData.countdownVal = LevelsDatabase.levelNodes[LevelsDatabase.currLevel].get_child(4).countdownVal

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if initializationCommplete == false:
		initializationAccumulationTime += _delta
		if initializationAccumulationTime > initializationAccumulationTimer:
			initializationAccumulationTime = 0.0
			_initialize()
		return

	#Only accumulate delay once for all players and not playerCount times!
	if InputsData.begin_delay && player_id == 0:
		InputsData.countdown_level_switching = false
		InputsData.delayed_reset_acc += _delta
		if InputsData.delayed_reset_acc > InputsData.delayed_reset_max:
			InputsData.delayed_reset_acc = 0.0
			InputsData.begin_delay = false
			LevelsDatabase.prevLevel = LevelsDatabase.currLevel

	if text_edit_input:
		return

	if LevelsDatabase.currLevel == LevelsDatabase.levelsCount:
		return

	position.y = clamp(position.y, -300, 250)
	InputsData.action_occurring = action_in_progress

func _physics_process(_delta: float) -> void:
	if initializationCommplete == false:
		return

	if text_edit_input:
		return

	if(action_in_progress):
		print("----dasdasd-----")
		pass

	move_and_slide()
	ghost_frames.append(position)

func _input(_event: InputEvent) -> void:
	if initializationCommplete == false:
		return

	if _event.is_pressed():
		InputsData.current_player_input_text = _event.as_text()

	# Detect Keyboard or Mouse
	if _event is InputEventKey or _event is InputEventMouse:
		if InputsData.is_using_gamepad:
			InputsData.is_using_gamepad = false
			#print("Switched to Keyboard/Mouse")
	# Detect Controller / Joypad
	elif _event is InputEventJoypadButton or _event is InputEventJoypadMotion:
		if not InputsData.is_using_gamepad:
			InputsData.is_using_gamepad = true
			#print("Switched to Controller")

	#Highlight the left card index.
	if _event.is_action_pressed(move_down_action):
		(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[1]].get_child(0) as AudioStreamPlayer2D).play()
		position.y += moveMaxPos
		print("down")

	#Highlight the right card index.
	if _event.is_action_pressed(move_up_action):
		(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[1]].get_child(0) as AudioStreamPlayer2D).play()
		position.y -= moveMaxPos
		print("up")

func is_any_text_focused(node: Node) -> bool:
	if node is TextEdit or node is LineEdit:
		if node.has_focus():
			return true
	
	for child in node.get_children():
		if is_any_text_focused(child):
			return true
			
	return false

func _unhandled_input(_event: InputEvent) -> void:
	# Checks the entire scene tree for an active text input
	if is_any_text_focused(get_tree().root):
		text_edit_input = true
	else:
		text_edit_input = false

func _start_new_run() -> void:
	ghost_frames = PackedVector2Array()
	run_start_global = owner.global_position


func _add_input_actions_for_this_player() -> void:
	# If its the last player - set the actions to be tied to keyboard!
	if player_id == (PlayersHelper.playersCount - 1):
		if not InputMap.has_action(move_down_action):
			InputMap.add_action(move_down_action)
			InputMap.action_set_deadzone(move_down_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_DPAD_DOWN
			eventAction1.device = player_id
			InputMap.action_add_event(move_down_action, eventAction1)
			var eventAction2 = InputEventJoypadMotion.new()
			eventAction2.axis = JoyAxis.JOY_AXIS_LEFT_Y
			eventAction2.axis_value = 1
			eventAction2.device = player_id
			InputMap.action_add_event(move_down_action, eventAction2)
			var eventAction3 = InputEventKey.new()
			eventAction3.keycode = Key.KEY_DOWN
			InputMap.action_add_event(move_down_action, eventAction3)
			var eventAction4 = InputEventKey.new()
			eventAction4.keycode = Key.KEY_S
			InputMap.action_add_event(move_down_action, eventAction4)
		if not InputMap.has_action(move_up_action):
			InputMap.add_action(move_up_action)
			InputMap.action_set_deadzone(move_up_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_DPAD_UP
			eventAction1.device = player_id
			InputMap.action_add_event(move_up_action, eventAction1)
			var eventAction2 = InputEventJoypadMotion.new()
			eventAction2.axis = JoyAxis.JOY_AXIS_LEFT_Y
			eventAction2.axis_value = -1
			eventAction2.device = player_id
			InputMap.action_add_event(move_up_action, eventAction2)
			var eventAction3 = InputEventKey.new()
			eventAction3.keycode = Key.KEY_UP
			InputMap.action_add_event(move_up_action, eventAction3)
			var eventAction4 = InputEventKey.new()
			eventAction4.keycode = Key.KEY_W
			InputMap.action_add_event(move_up_action, eventAction4)
	else:
	# Otherwise, set the actions tied to the joypad accordingly!
		if not InputMap.has_action(move_down_action):
			InputMap.add_action(move_down_action)
			InputMap.action_set_deadzone(move_down_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_DPAD_DOWN
			eventAction1.device = player_id
			InputMap.action_add_event(move_down_action, eventAction1)
			var eventAction2 = InputEventJoypadMotion.new()
			eventAction2.axis = JoyAxis.JOY_AXIS_LEFT_Y
			eventAction2.axis_value = 1
			eventAction2.device = player_id
			InputMap.action_add_event(move_down_action, eventAction2)
		if not InputMap.has_action(move_up_action):
			InputMap.add_action(move_up_action)
			InputMap.action_set_deadzone(move_up_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_DPAD_UP
			eventAction1.device = player_id
			InputMap.action_add_event(move_up_action, eventAction1)
			var eventAction2 = InputEventJoypadMotion.new()
			eventAction2.axis = JoyAxis.JOY_AXIS_LEFT_Y
			eventAction2.axis_value = -1
			eventAction2.device = player_id
			InputMap.action_add_event(move_up_action, eventAction2)
