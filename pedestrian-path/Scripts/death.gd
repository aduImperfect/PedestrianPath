extends Area2D

class_name DeathFuncs

@export var initial_setup : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if initial_setup == false:
		#for k in PlayersHelper.playerNodes.size():
			#playersEnteredGoal.append(false)
		initial_setup = true

func _on_body_entered(body: Node2D) -> void:
	_player_death(body)

static func _player_death(body: Node2D) -> void:
	if body.owner != null && body.owner.name.contains("Player") == false:
		return

	(AudioDatabase.audioNodes[AudioDatabase.audio_styles_list_sttc[7]].get_child(0) as AudioStreamPlayer2D).play()

	if body.ghost_frames.size() > 0:
		PlayersHelper.record_ghost_run(body.player_id, body.run_start_global, body.ghost_frames)

	body.position = Vector2(0.0, 0.0)
	body.owner.global_position = LevelsDatabase.levelNodes[LevelsDatabase.currLevel].get_child(0).global_position
	InputsData.jump_speed = 0.0
	InputsData.move_speed = 0.0
	body.is_moving_forward = false
	body.is_moving_backward = false
	body.is_jumping_upward = false
	body.is_jumping_forward = false
	body.is_speeding_up = false
	body.is_speeding_down = false
	body.is_stopping = false
	body.action_in_progress = false

	body._start_new_run()
	print("Player Died!")
