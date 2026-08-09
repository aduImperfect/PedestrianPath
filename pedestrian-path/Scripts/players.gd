class_name PlayersHelper

const PLAYER_SCENE = preload("res://Scenes/player.tscn")
const GHOST_SCENE = preload("res://Scenes/ghost.tscn")

static var playerNodes : Array[Node2D] = []
static var playersCount : int = 0

# Where ghost nodes get added as children (set by level_gen.gd)
static var ghostContainer : Node2D = null

# player_id -> Array[Ghost] currently alive for that player
static var ghostsByPlayer : Dictionary = {}

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

static func _set_player_info() -> void:
	print("--------------------")
	if SaveLoadHelper.fileExist:
		playersCount = SaveLoadHelper.save_data.get("game", 1).get("player", 1).get("count", 1)
		print("Players Count: ", playersCount)
	else:
		#Make sure the base default value is set to 1.
		playersCount = 1
	print("--------------------")

## Call this once, from level_gen, before spawning players.
static func _set_ghost_container(container: Node2D) -> void:
	ghostContainer = container
	ghostsByPlayer.clear()

## Adds a new ghost that replays `frames` (local-space positions recorded
## during a run) starting from `start_global` (world position at the start
## of that run). Accumulates alongside any existing ghosts for this player.
static func record_ghost_run(player_id: int, start_global: Vector2, frames: PackedVector2Array) -> void:
	if ghostContainer == null or frames.is_empty():
		return

	var ghost_instance : Ghost = GHOST_SCENE.instantiate()
	ghostContainer.add_child(ghost_instance)
	ghost_instance.setup(player_id, start_global, frames)

	if not ghostsByPlayer.has(player_id):
		ghostsByPlayer[player_id] = []
	ghostsByPlayer[player_id].append(ghost_instance)

## Clears all accumulated ghosts for one player (e.g. when they finish a level).
static func clear_ghosts_for_player(player_id: int) -> void:
	if not ghostsByPlayer.has(player_id):
		return
	for ghost in ghostsByPlayer[player_id]:
		if is_instance_valid(ghost):
			ghost.queue_free()
	ghostsByPlayer.erase(player_id)
