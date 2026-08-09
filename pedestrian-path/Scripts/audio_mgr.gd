extends Node2D

@export var audio_styles_list : Array[AudioDatabase.AudioStyle]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioDatabase._set_values()

	if SaveLoadHelper.fileExist:
		AudioDatabase._reset_volume_values()
	else:
		AudioDatabase._inital_volume_values()

	_spawn_audio()
	AudioDatabase.audioMgrNode = self
	AudioDatabase.audio_styles_list_sttc = audio_styles_list

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	AudioDatabase.audio_styles_list_sttc = audio_styles_list
	AudioDatabase._set_current_volumes()

func _spawn_audio() -> void:
	for k in AudioDatabase.audioCount:
		var audio_instance = load(AudioDatabase.AUDIO_SCENES[k]).instantiate()
		add_child(audio_instance)
		AudioDatabase.audioNodes.append(audio_instance)
	#Set master volume only after all the audioNodes have been setup!
	AudioDatabase._set_master_volume()
