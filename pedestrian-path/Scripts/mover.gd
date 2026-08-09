extends Node2D

class_name Mover

@export var travelPoss : Array[Vector2]

@export var prevIndex : int
@export var currIndex : int
@export var flipDir : bool

@export var lerpStart : float = 0.0
@export var lerpEnd : float = 1.0
@export var lerpTVal : float = 0.0

@export var waitTimerAccumulation : float = 0.0
@export var waitTimer : float = 1.0
@export var inMovementProgress : bool
@export var readyForNextPoint : bool

@export var moverSpeed : float

static var onMover : bool
static var followerNode : Node2D

static var originalFollowerParent : Node2D
static var origParent : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lerpStart = 0.0
	lerpEnd = 1.0
	lerpTVal = 0.0
	moverSpeed = 0.2
	waitTimerAccumulation = 0.0
	waitTimer = 1.0
	inMovementProgress = false
	readyForNextPoint = true
	prevIndex = 0
	currIndex = 0
	flipDir = false
	position = travelPoss[0]
	onMover = false
	originalFollowerParent = self
	origParent = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if onMover && (originalFollowerParent == origParent):
		print("OriginalFollowerParent Bef: ", originalFollowerParent)
		originalFollowerParent = followerNode.owner
		print("OriginalFollowerParent Aft: ", originalFollowerParent)
		followerNode.global_position = global_position - Vector2(0.0, 30.0)
		print("Follower Owner Bef: ", followerNode.owner)
		followerNode.reparent(self)
		followerNode.owner = self
		print("Follower Owner Aft Last: ", followerNode.owner)

	if readyForNextPoint:
		waitTimerAccumulation += _delta
		if waitTimerAccumulation > waitTimer:
			waitTimerAccumulation = 0.0
			inMovementProgress = true
			readyForNextPoint = false

	if inMovementProgress:
		_movement(_delta)

func _movement(_delta : float) -> void:
	lerpTVal += _delta * moverSpeed
	if lerpTVal <= lerpEnd:
		position = lerp(travelPoss[prevIndex], travelPoss[currIndex], lerpTVal)
	else:
		readyForNextPoint = true
		lerpTVal = 0.0
		prevIndex = currIndex
		if (flipDir == false) and (currIndex == (travelPoss.size() - 1)):
			flipDir = true
			currIndex -= 1
		elif flipDir == false:
			currIndex += 1
		elif flipDir and (currIndex == 0):
			flipDir = false
			currIndex += 1
		elif flipDir:
			currIndex -= 1
