class_name CameraHelper

# Camera settings
static var smoothing_speed : float
static var camera_position : Vector2

static func _set_initial_camera_values_sp() -> void:
	smoothing_speed = 5.0
	camera_position = Vector2(640.0, 360.0)

static func _reset_values_sp() -> void:
	smoothing_speed = SaveLoadHelper.save_data.get("game", 1).get("camera", 1).get("smoothing_speed", 1)
	print("Camera Smoothing Speed: ", smoothing_speed)
