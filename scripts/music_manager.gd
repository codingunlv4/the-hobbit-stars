extends Node

const MISTY_MOUNTAINS := "res://audio/misty_mountains.ogg"
const MISTY_MOUNTAINS_MP3 := "res://audio/misty_mountains.mp3"

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = &"Master"
	_player.volume_db = -8.0
	add_child(_player)
	play_misty_mountains()


func play_misty_mountains() -> void:
	var stream := _load_music_stream()
	if not stream:
		push_warning(
			"Music: Add 'misty_mountains.ogg' or 'misty_mountains.mp3' to res://audio/ "
			+ "(see res://audio/README.txt)."
		)
		return

	if stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamMP3:
		stream.loop = true

	_player.stream = stream
	_player.play()


func _load_music_stream() -> AudioStream:
	if ResourceLoader.exists(MISTY_MOUNTAINS):
		return load(MISTY_MOUNTAINS)
	if ResourceLoader.exists(MISTY_MOUNTAINS_MP3):
		return load(MISTY_MOUNTAINS_MP3)
	return null
