extends RigidBody2D

@export var initial_setup : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if initial_setup == false:
		initial_setup = true

func _on_body_entered(_body: Node2D) -> void:
	if LevelsDatabase.currLevel >= LevelsDatabase.levelsCount:
		return

	#for k in PlayersHelper.playerNodes.size():
		#if body.owner.name == PlayersHelper.playerNodes[k].name:
			##print("Goal at: " + owner.owner.name + " reached by Player: " + body.owner.name)
			#if body.is_moving_forward && body.action_in_progress:
				#body.move_timer = 0.0
				#body.lerpTVal = 0.0
				#body.is_moving_forward = false
				#body.action_in_progress = false
				#body.long_press_triggered = false
				#body.old_position = body.position
				#body.new_position = body.position
				#break
