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

@export var select_action: String
@export var move_left_action: String
@export var move_right_action: String
@export var cancel_action: String

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

	select_action = "ui_select_p" + str(player_id)
	move_left_action = "ui_left_p" + str(player_id)
	move_right_action = "ui_right_p" + str(player_id)
	cancel_action = "ui_cancel_p" + str(player_id)

	_add_input_actions_for_this_player()
	_start_new_run()

	#Lazy check only during last player initialization finishing as the InputsData are common static values currently!
	if player_id == (PlayersHelper.playersCount - 1):
		initializationCommplete = true
		SaveLoadHelper.save_game()
		if AudioDatabase.audio_styles_list_sttc.size() != 0:
			(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[0]].get_child(0) as AudioStreamPlayer2D).play()

	CountdownData.countdownVal = LevelsDatabase.levelNodes[LevelsDatabase.currLevel].get_child(4).countdownVal

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

	if InputsData.countdown_level_switching && (LevelsDatabase.currLevel == LevelsDatabase.prevLevel):
		YouFailed.showNow = true
		DeathFuncs._player_death(self)
		InputsData.countdown_level_switching = false
		CountdownData.countdownVal = LevelsDatabase.levelNodes[LevelsDatabase.currLevel].get_child(4).countdownVal
		CardsHelper.cardLevelCloseInit = false

	#Countdown went to 0 and level not complete!
	if CountdownData.countdownVal == 0:
		InputsData.countdown_level_switching = true

	InputsData.action_occurring = action_in_progress

	if is_on_floor():
		if (Mover.onMover == false) && (Mover.originalFollowerParent == Mover.origParent):
			var collision = get_last_slide_collision()
			if collision:
				var obj = collision.get_collider()
				if obj.owner.name.contains("Mover"):
					Mover.onMover = true
					Mover.followerNode = self
	else:
		if Mover.onMover:
			print("Follower Owner Bef: ", Mover.followerNode.owner)
			reparent(Mover.originalFollowerParent)
			owner =  Mover.originalFollowerParent
			print("Follower Owner Aft: ", Mover.followerNode.owner)
			print("OriginalFollowerParent Bef: ", Mover.originalFollowerParent)
			Mover.originalFollowerParent = Mover.origParent
			print("OriginalFollowerParent Bef: ", Mover.originalFollowerParent)
			Mover.onMover = false


	if wallHit:
		if moveDir > 0.0:
			position.x -= _delta * wallBounce
		elif moveDir < 0.0:
			position.x += _delta * wallBounce
		wallHitDuration += _delta
		if wallHitDuration > wallHitTimer:
			wallHitDuration = 0.0
			wallHit = false
			old_position = position
			new_position = position
			CountdownData.countdownVal -= 1

	if is_on_ceiling():
		move_timer = 0.0
		lerpTVal = 0.0
		if is_jumping_forward or is_jumping_upward:
			CountdownData.countdownVal -= 1
		is_moving_forward = false
		is_moving_backward = false
		is_jumping_upward = false
		is_jumping_forward = false
		action_in_progress = false
		long_press_triggered = false
		old_position = position
		new_position = position

	if is_on_wall():
		move_timer = 0.0
		lerpTVal = 0.0
		is_moving_forward = false
		is_moving_backward = false
		is_jumping_upward = false
		is_jumping_forward = false
		action_in_progress = false
		long_press_triggered = false
		wallHit = true

	if is_moving_forward and not action_in_progress:
		lerpTVal = 0.0
		moveDir = 1.0
		(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[6]].get_child(0) as AudioStreamPlayer2D).play()
		old_position = position
		new_position = position + Vector2(InputsData.move_distance, 0.0)
		action_in_progress = true
	elif is_moving_backward and not action_in_progress:
		lerpTVal = 0.0
		moveDir = -1.0
		(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[6]].get_child(0) as AudioStreamPlayer2D).play()
		old_position = position
		new_position = position - Vector2(InputsData.move_distance, 0.0)
		action_in_progress = true

	if is_on_floor():
		if is_jumping_upward and not action_in_progress:
			(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[8]].get_child(0) as AudioStreamPlayer2D).play()
			action_in_progress = true
		elif is_jumping_forward and not action_in_progress:
			(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[8]].get_child(0) as AudioStreamPlayer2D).play()
			action_in_progress = true
		else:
			grounded = true
	else:
		grounded = false

	if is_moving_forward && action_in_progress:
		move_timer += _delta
		if move_timer > move_duration:
			move_timer = 0.0
			lerpTVal = 0.0
			is_moving_forward = false
			action_in_progress = false
			long_press_triggered = false
			old_position = position
			new_position = position
			CountdownData.countdownVal -= 1
		elif position.x >= new_position.x:
			move_timer = 0.0
			lerpTVal = 0.0
			is_moving_forward = false
			action_in_progress = false
			long_press_triggered = false
			old_position = position
			new_position = position
			CountdownData.countdownVal -= 1

	if is_moving_backward && action_in_progress:
		move_timer += _delta
		if move_timer > move_duration:
			move_timer = 0.0
			lerpTVal = 0.0
			is_moving_backward = false
			action_in_progress = false
			long_press_triggered = false
			old_position = position
			new_position = position
			CountdownData.countdownVal -= 1
		elif position.x <= new_position.x:
			move_timer = 0.0
			lerpTVal = 0.0
			is_moving_backward = false
			action_in_progress = false
			long_press_triggered = false
			old_position = position
			new_position = position
			CountdownData.countdownVal -= 1

	if is_jumping_forward && action_in_progress:
		move_timer += _delta
		if move_timer > move_duration:
			move_timer = 0.0
			lerpTVal = 0.0
			is_jumping_forward = false
			action_in_progress = false
			long_press_triggered = false
			CountdownData.countdownVal -= 1

	if is_jumping_upward && action_in_progress:
		move_timer += _delta
		if move_timer > move_duration:
			move_timer = 0.0
			lerpTVal = 0.0
			is_jumping_upward = false
			action_in_progress = false
			long_press_triggered = false
			CountdownData.countdownVal -= 1

	#Long Press Action!
	if is_holding and not long_press_triggered and not action_in_progress:
		hold_timer += _delta
		CardsHelper.handNodes[InputsData.curr_input_card_index].get_child(0).selectedDelayAccumulation = hold_timer
		InputsData.curr_input_card_selected = true
		if hold_timer >= hold_duration:
			InputsData.curr_input_card_selection_complete = true
			is_holding = false
			hold_timer = 0.0
			move_timer = 0.0
			long_press_triggered = true
			#Mover.onMover = false
			_on_long_press()

func _physics_process(_delta: float) -> void:
	if initializationCommplete == false:
		return

	if text_edit_input:
		return

	if velocity.x > 0.0:
		velocity.x -= _delta * InputsData.jump_speed_dec
	else:
		velocity.x = 0.0

	if not is_on_floor():
		#Gravity fall!
		velocity.y += gravity * _delta * 10.0

	if is_moving_forward && action_in_progress:
		lerpTVal += _delta * InputsData.max_move_speed
		if lerpTVal <= lerpEnd:
			position = lerp(old_position, new_position, lerpTVal)

	if is_moving_backward && action_in_progress:
		lerpTVal += _delta * InputsData.max_move_speed
		if lerpTVal <= lerpEnd:
			position = lerp(old_position, new_position, lerpTVal)

	if is_jumping_upward and action_in_progress:
		velocity.y = -(InputsData.max_jump_speed)

	if is_jumping_forward and action_in_progress:
		velocity.y = -(InputsData.max_jump_speed)
		velocity.x = InputsData.move_distance / 6

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

	# Detect the exact frame the button is first pressed down
	if _event.is_action_pressed(select_action):
		(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[2]].get_child(0) as AudioStreamPlayer2D).play()
		is_holding = true
		hold_timer = 0.0
		long_press_triggered = false
	# Detect when the button is released
	elif _event.is_action_released(select_action):
		InputsData.curr_input_card_selected = false
		InputsData.curr_input_card_selection_complete = false
		is_holding = false
		# Optional: Trigger a normal "tap" action if released before the threshold
		if not long_press_triggered:
			_on_short_press()

	#Highlight the left card index.
	if _event.is_action_pressed(move_left_action):
		(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[1]].get_child(0) as AudioStreamPlayer2D).play()
		InputsData.curr_input_card_index -= 1
		if InputsData.curr_input_card_index < 0:
			InputsData.curr_input_card_index = 0

	#Highlight the right card index.
	if _event.is_action_pressed(move_right_action):
		(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[1]].get_child(0) as AudioStreamPlayer2D).play()
		InputsData.curr_input_card_index += 1
		if InputsData.curr_input_card_index > (CardsHelper.handNodes.size() - 1):
			InputsData.curr_input_card_index = (CardsHelper.handNodes.size() - 1)

	#Deselect all cards (helps see cards in unhighlighted mode if required for example)
	if _event.is_action_pressed(cancel_action):
		InputsData.curr_input_card_index = -1
		if InputsData.curr_input_card_index < 0:
			InputsData.curr_input_card_index = 0

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

func _on_short_press() -> void:
	print("Short press detected!")

func _on_long_press() -> void:
	print("Long press successfully triggered!")
	if InputsData.curr_input_card_value == CardType.CARD_TYPE_ENUM.MOVE_FORWARD:
		is_moving_forward = true
	elif InputsData.curr_input_card_value == CardType.CARD_TYPE_ENUM.MOVE_BACKWARD:
		is_moving_backward = true
	elif InputsData.curr_input_card_value == CardType.CARD_TYPE_ENUM.JUMP_UPWARD:
		is_jumping_upward = true
	elif InputsData.curr_input_card_value == CardType.CARD_TYPE_ENUM.JUMP_FORWARD:
		#Both are true!
		#is_moving_forward = true
		is_jumping_forward = true
	elif InputsData.curr_input_card_value == CardType.CARD_TYPE_ENUM.SPEED_UP:
		is_speeding_up = true
	elif InputsData.curr_input_card_value == CardType.CARD_TYPE_ENUM.SPEED_DOWN:
		is_speeding_down = true
	elif InputsData.curr_input_card_value == CardType.CARD_TYPE_ENUM.STOP:
		is_stopping = true
	action_in_progress = false
	move_timer = 0.0

func _add_input_actions_for_this_player() -> void:
	# If its the last player - set the actions to be tied to keyboard!
	if player_id == (PlayersHelper.playersCount - 1):
		if not InputMap.has_action(select_action):
			InputMap.add_action(select_action)
			InputMap.action_set_deadzone(select_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_A
			eventAction1.device = player_id
			InputMap.action_add_event(select_action, eventAction1)
			var eventAction2 = InputEventJoypadMotion.new()
			eventAction2.axis = JoyAxis.JOY_AXIS_TRIGGER_RIGHT
			eventAction2.device = player_id
			InputMap.action_add_event(select_action, eventAction2)
			var eventAction3 = InputEventKey.new()
			eventAction3.keycode = Key.KEY_SPACE
			InputMap.action_add_event(select_action, eventAction3)
		if not InputMap.has_action(move_left_action):
			InputMap.add_action(move_left_action)
			InputMap.action_set_deadzone(move_left_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_DPAD_LEFT
			eventAction1.device = player_id
			InputMap.action_add_event(move_left_action, eventAction1)
			var eventAction2 = InputEventJoypadMotion.new()
			eventAction2.axis = JoyAxis.JOY_AXIS_LEFT_X
			eventAction2.axis_value = -1
			eventAction2.device = player_id
			InputMap.action_add_event(move_left_action, eventAction2)
			var eventAction3 = InputEventKey.new()
			eventAction3.keycode = Key.KEY_LEFT
			InputMap.action_add_event(move_left_action, eventAction3)
			var eventAction4 = InputEventKey.new()
			eventAction4.keycode = Key.KEY_A
			InputMap.action_add_event(move_left_action, eventAction4)
		if not InputMap.has_action(move_right_action):
			InputMap.add_action(move_right_action)
			InputMap.action_set_deadzone(move_right_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_DPAD_RIGHT
			eventAction1.device = player_id
			InputMap.action_add_event(move_right_action, eventAction1)
			var eventAction2 = InputEventJoypadMotion.new()
			eventAction2.axis = JoyAxis.JOY_AXIS_LEFT_X
			eventAction2.axis_value = 1
			eventAction2.device = player_id
			InputMap.action_add_event(move_right_action, eventAction2)
			var eventAction3 = InputEventKey.new()
			eventAction3.keycode = Key.KEY_RIGHT
			InputMap.action_add_event(move_right_action, eventAction3)
			var eventAction4 = InputEventKey.new()
			eventAction4.keycode = Key.KEY_D
			InputMap.action_add_event(move_right_action, eventAction4)
		if not InputMap.has_action(cancel_action):
			InputMap.add_action(cancel_action)
			InputMap.action_set_deadzone(cancel_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_B
			eventAction1.device = player_id
			InputMap.action_add_event(cancel_action, eventAction1)
			var eventAction2 = InputEventKey.new()
			eventAction2.keycode = Key.KEY_ESCAPE
			InputMap.action_add_event(cancel_action, eventAction2)
	else:
	# Otherwise, set the actions tied to the joypad accordingly!
		if not InputMap.has_action(select_action):
			InputMap.add_action(select_action)
			InputMap.action_set_deadzone(select_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_A
			eventAction1.device = player_id
			InputMap.action_add_event(select_action, eventAction1)
			var eventAction2 = InputEventJoypadMotion.new()
			eventAction2.axis = JoyAxis.JOY_AXIS_TRIGGER_RIGHT
			eventAction2.device = player_id
			InputMap.action_add_event(select_action, eventAction2)
		if not InputMap.has_action(move_left_action):
			InputMap.add_action(move_left_action)
			InputMap.action_set_deadzone(move_left_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_DPAD_LEFT
			eventAction1.device = player_id
			InputMap.action_add_event(move_left_action, eventAction1)
			var eventAction2 = InputEventJoypadMotion.new()
			eventAction2.axis = JoyAxis.JOY_AXIS_LEFT_X
			eventAction2.axis_value = -1
			eventAction2.device = player_id
			InputMap.action_add_event(move_left_action, eventAction2)
		if not InputMap.has_action(move_right_action):
			InputMap.add_action(move_right_action)
			InputMap.action_set_deadzone(move_right_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_DPAD_RIGHT
			eventAction1.device = player_id
			InputMap.action_add_event(move_right_action, eventAction1)
			var eventAction2 = InputEventJoypadMotion.new()
			eventAction2.axis = JoyAxis.JOY_AXIS_LEFT_X
			eventAction2.axis_value = 1
			eventAction2.device = player_id
			InputMap.action_add_event(move_right_action, eventAction2)
		if not InputMap.has_action(cancel_action):
			InputMap.add_action(cancel_action)
			InputMap.action_set_deadzone(cancel_action, 0.2)
			var eventAction1 = InputEventJoypadButton.new()
			eventAction1.button_index = JoyButton.JOY_BUTTON_B
			eventAction1.device = player_id
			InputMap.action_add_event(cancel_action, eventAction1)
