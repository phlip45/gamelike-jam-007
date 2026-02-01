extends AudioStreamPlayer2D
class_name ActorSoundPlayer

func play_sound(audio_stream:AudioStream, override:bool = false):
	#if playing and !override: return
	pitch_scale = randf_range(.85,1.15)
	stream = audio_stream
	play()
