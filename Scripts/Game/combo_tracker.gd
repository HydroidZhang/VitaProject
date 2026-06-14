class_name ComboTracker
extends RefCounted

var current_combo: int = 0
var max_combo: int = 0
var _last_match_time_sec: float = -999.0


func reset() -> void:
	current_combo = 0
	max_combo = 0
	_last_match_time_sec = -999.0


func register_match(elapsed_sec: float) -> int:
	if current_combo > 0 and (elapsed_sec - _last_match_time_sec) <= GameplayConstants.COMBO_WINDOW_SEC:
		current_combo += 1
	else:
		current_combo = 1

	_last_match_time_sec = elapsed_sec
	max_combo = maxi(max_combo, current_combo)
	return current_combo


static func bonus_for(combo: int) -> int:
	if combo < 2:
		return 0
	return (combo - 1) * GameplayConstants.COMBO_BONUS_PER_LEVEL
