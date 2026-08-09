extends Area2D

var speed : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = randf_range(20.0, 30.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position.x -= speed * _delta
