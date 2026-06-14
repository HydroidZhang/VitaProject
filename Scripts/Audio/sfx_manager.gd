extends Node

const POOL_SIZE := 4

var _players: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0
var _streams: Dictionary = {}


func _ready() -> void:
	for index in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = &"Master"
		add_child(player)
		_players.append(player)

	_streams = {
		"click": _make_tone(880.0, 0.05, 0.18),
		"match": _make_tone(660.0, 0.12, 0.22, [1320.0]),
		"collision": _make_collision_tone(),
		"clear": _make_tone(523.0, 0.35, 0.28, [784.0, 1046.0]),
		"shuffle": _make_tone(392.0, 0.18, 0.2, [494.0]),
	}


func play_click() -> void:
	_play("click")


func play_match() -> void:
	_play("match")


func play_collision() -> void:
	_play("collision")


func play_clear() -> void:
	_play("clear")


func play_shuffle() -> void:
	_play("shuffle")


func _play(stream_key: String) -> void:
	var stream: AudioStream = _streams.get(stream_key)
	if stream == null:
		return

	var player := _players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % POOL_SIZE
	player.stream = stream
	player.play()


func _make_tone(
	base_freq: float,
	duration: float,
	volume: float,
	extra_freqs: Array = [],
) -> AudioStreamWAV:
	var mix_rate := 22050
	var frame_count := int(mix_rate * duration)
	var freqs: Array[float] = [base_freq]
	freqs.append_array(extra_freqs)

	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = mix_rate
	audio.stereo = false

	var data := PackedByteArray()
	data.resize(frame_count * 2)

	for frame in frame_count:
		var t := float(frame) / float(mix_rate)
		var envelope := 1.0
		var attack := duration * 0.08
		var release_start := duration * 0.55
		if t < attack:
			envelope = t / attack
		elif t > release_start:
			envelope = 1.0 - (t - release_start) / (duration - release_start)

		var sample := 0.0
		for freq in freqs:
			sample += sin(TAU * freq * t)
		sample = sample / float(freqs.size()) * envelope * volume

		var sample_16 := int(clampi(int(sample * 32767.0), -32768, 32767))
		data[frame * 2] = sample_16 & 0xFF
		data[frame * 2 + 1] = (sample_16 >> 8) & 0xFF

	audio.data = data
	return audio


func _make_collision_tone() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 0.13
	var frame_count := int(mix_rate * duration)

	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = mix_rate
	audio.stereo = false

	var data := PackedByteArray()
	data.resize(frame_count * 2)

	for frame in frame_count:
		var t := float(frame) / float(mix_rate)
		var thump_env := exp(-t * 38.0)
		var clack_env := exp(-t * 52.0)
		var thump := sin(TAU * 165.0 * t) * thump_env * 0.55
		var clack := sin(TAU * 720.0 * t) * clack_env * 0.28
		var tick := sin(TAU * 1180.0 * t) * exp(-t * 70.0) * 0.12
		var sample := (thump + clack + tick) * 0.9

		var sample_16 := int(clampi(int(sample * 32767.0), -32768, 32767))
		data[frame * 2] = sample_16 & 0xFF
		data[frame * 2 + 1] = (sample_16 >> 8) & 0xFF

	audio.data = data
	return audio
