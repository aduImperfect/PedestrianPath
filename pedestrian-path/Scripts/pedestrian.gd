extends Area2D

var speed : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = randf_range(30.0, 50.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position.x -= speed * _delta

func _on_body_entered(body: Node2D) -> void:
	if body.owner != null && body.owner.name.contains("Player") == false:
		return
	print("Player Here!")
	PlayersHelper.coinCount += 20
	hide()
	global_position.x = -100.0
