extends Area2D

@export var playersEnteredGoal : Array[bool] = []

@export var initial_setup : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if initial_setup == false:
		for k in PlayersHelper.playerNodes.size():
			playersEnteredGoal.append(false)
		initial_setup = true

func _on_body_entered(body: Node2D) -> void:
	if LevelsDatabase.currLevel >= LevelsDatabase.levelsCount:
		body.global_position = global_position
		body.get_child(0).is_moving_forward = false
		body.get_child(0).is_moving_backward = false
		body.get_child(0).is_jumping_upward = false
		body.get_child(0).is_jumping_forward = false
		body.get_child(0).is_speeding_up = false
		body.get_child(0).is_speeding_down = false
		body.get_child(0).is_stopping = false
		body.get_child(0).long_press_triggered = false
		body.get_child(0).action_in_progress = false
		body.get_child(0).move_timer = 0.0
		body.get_child(0).lerpTVal = 0.0
		body.get_child(0).old_position = body.get_child(0).position
		body.get_child(0).new_position = body.get_child(0).position
		InputsData.move_speed = 0.0
		body.is_moving_forward = false
		body.action_in_progress = false
		return

	for k in PlayersHelper.playerNodes.size():
		if body.owner.name == PlayersHelper.playerNodes[k].name:
			#print("Goal at: " + owner.owner.name + " reached by Player: " + body.owner.name)
			playersEnteredGoal[k] = true
			break

	var allPlayersEntered : bool = (playersEnteredGoal.size() > 0)
	for k in playersEnteredGoal.size():
		if playersEnteredGoal[k] == false:
			allPlayersEntered = false
			break

	#Only progress to next level if all players reached!
	if allPlayersEntered && LevelsDatabase.lvlSwitchInProgress == false:
		set_deferred("monitoring", false)
		LevelsDatabase._level_switcher()
		(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[5]].get_child(0) as AudioStreamPlayer2D).play()
