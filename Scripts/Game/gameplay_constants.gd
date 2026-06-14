class_name GameplayConstants
extends RefCounted

const MATCH_SCORE := 320

## 道具每关可用次数（可在本文件调整）
const EARLY_LEVEL_MAX_ID := 10
const EARLY_SHUFFLE_CHARGES := 2
const EARLY_HINT_CHARGES := 2
const LATE_SHUFFLE_CHARGES := 3
const LATE_HINT_CHARGES := 3


static func shuffle_charges_for_level(level_id: int) -> int:
	return EARLY_SHUFFLE_CHARGES if level_id <= EARLY_LEVEL_MAX_ID else LATE_SHUFFLE_CHARGES


static func hint_charges_for_level(level_id: int) -> int:
	return EARLY_HINT_CHARGES if level_id <= EARLY_LEVEL_MAX_ID else LATE_HINT_CHARGES
