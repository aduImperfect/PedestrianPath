extends Node2D
class_name Ghost

var player_id : int = -1
var start_global : Vector2 = Vector2.ZERO
var frames : PackedVector2Array = PackedVector2Array()
var frame_index : int = 0

func setup(p_player_id: int, p_start_global: Vector2, p_frames: PackedVector2Array) -> void:
	player_id = p_player_id
	start_global = p_start_global
	frames = p_frames
	frame_index = 0
	if frames.size() > 0:
		global_position = start_global + frames[0]

func _physics_process(_delta: float) -> void:
	if frames.is_empty():
		return

	global_position = start_global + frames[frame_index]
	frame_index += 1
	if frame_index >= frames.size():
		frame_index = 0 # loop the ghost run forever
