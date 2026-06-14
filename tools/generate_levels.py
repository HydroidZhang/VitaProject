#!/usr/bin/env python3
"""Generate 20 simple levels and verify solvability."""

import json
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LAYOUT_DIR = ROOT / "Data" / "Layouts"
LEVELS_PATH = ROOT / "Data" / "Levels" / "levels.json"

TW, TH = 2, 3
MAX_NODES = 50000
ATTEMPTS = 800

NAMES = [
    "初出茅庐", "小试牛刀", "渐入佳境", "稳步前行", "双层进阶",
    "叠层挑战", "双层精通", "塔影成双", "步步为营", "双层大师",
    "三层起步", "层峦渐起", "高塔三重", "叠影重重", "深塔探秘",
    "迷宫三层", "大师前奏", "巅峰预备", "终极试炼", "麻将宗师",
]

ALL_TILES = [
    "wan_1", "wan_2", "wan_3", "wan_4", "wan_5", "wan_6", "wan_7", "wan_8", "wan_9",
    "tiao_1", "tiao_2", "tiao_3", "tiao_4", "tiao_5", "tiao_6", "tiao_7", "tiao_8", "tiao_9",
    "bing_1", "bing_2", "bing_3", "bing_4", "bing_5", "bing_6", "bing_7", "bing_8", "bing_9",
    "wind_east", "wind_south", "wind_west", "wind_north",
    "dragon_red", "dragon_green", "dragon_white",
]


def layers(level_id: int) -> int:
    if level_id <= 1:
        return 1
    if level_id <= 10:
        return 2
    return 3


def tiles(level_id: int) -> int:
    if level_id <= 1:
        return 8
    return 8 + (level_id - 1) * 2


def dist_three(total: int) -> list[int]:
    counts = [total - 4, 2, 2]
    layer = 1
    while layer < 3 and counts[layer] < counts[layer - 1] - 2:
        counts[layer] += 2
        counts[0] -= 2
        layer += 1
    if counts[0] < 2 or sum(counts) != total:
        raise ValueError(f"bad 3-layer split for {total}: {counts}")
    return counts


def dist_two_candidates(total: int) -> list[list[int]]:
    cands = []
    for top in range(2, total - 2, 2):
        bottom = total - top
        if bottom >= 4 and bottom >= top - 2:
            cands.append([bottom, top])
    return cands or [[total - 4, 4]]


def dist_three_candidates(total: int) -> list[list[int]]:
    base = dist_three(total)
    cands = [base]
    # slightly wider upper rows
    alt = [base[0] - 2, base[1] + 2, base[2]]
    if alt[0] >= 2 and sum(alt) == total and alt not in cands:
        cands.append(alt)
    return cands


def distribute_candidates(total: int, layer_count: int) -> list[list[int]]:
    if layer_count == 1:
        return [[total]]
    if layer_count == 2:
        return dist_two_candidates(total)
    return dist_three_candidates(total)


def build_cells_for(level_id: int, per_layer: list[int]) -> list[dict]:
    layer_count = len(per_layer)
    cells = []
    for layer, count in enumerate(per_layer):
        y = 3 + layer_count - layer
        for index in range(count):
            cells.append({"x": layer + index * 2, "y": y, "layer": layer})
    return cells


def try_level(level_id: int):
    total = tiles(level_id)
    layer_count = layers(level_id)
    pool = pool_for(level_id)
    for per_layer in distribute_candidates(total, layer_count):
        cells = build_cells_for(level_id, per_layer)
        if solvable(cells, pool):
            return cells, per_layer
    return None, None


def y_overlap(a, b):
    return a["y"] < b["y"] + TH and b["y"] < a["y"] + TH


def x_overlap(a, b):
    return a["x"] < b["x"] + TW and b["x"] < a["x"] + TW


def is_covered(slot, slots):
    for other in slots:
        if other is slot or other["layer"] <= slot["layer"]:
            continue
        if x_overlap(slot, other) and y_overlap(slot, other):
            return True
    return False


def side_blocks(slot, slots):
    lb = rb = False
    for other in slots:
        if other is slot or other["layer"] != slot["layer"] or not y_overlap(slot, other):
            continue
        if other["x"] == slot["x"] - TW:
            lb = True
        if other["x"] == slot["x"] + TW:
            rb = True
    return lb, rb


def is_free(slot, slots):
    lb, rb = side_blocks(slot, slots)
    return not is_covered(slot, slots) and not (lb and rb)


def solve(slots, visited=0):
    if not slots:
        return True
    if visited > MAX_NODES:
        return False
    free = [s for s in slots if is_free(s, slots)]
    for i, a in enumerate(free):
        for b in free[i + 1:]:
            if a["tile_id"] != b["tile_id"]:
                continue
            nxt = [s for s in slots if s is not a and s is not b]
            if solve(nxt, visited + 1):
                return True
    return False


def pool_for(level_id: int) -> list[str]:
    pairs = tiles(level_id) // 2
    size = min(len(ALL_TILES), max(pairs + 4, 8))
    return ALL_TILES[:size]


def solvable(cells, pool) -> bool:
    pairs = len(cells) // 2
    for seed in range(60):
        rng = random.Random(seed)
        for _ in range(ATTEMPTS // 60 + 1):
            types = [pool[i % len(pool)] for i in range(pairs)]
            ids = []
            for t in types:
                ids.extend([t, t])
            rng.shuffle(ids)
            slots = [{**c, "tile_id": tid} for c, tid in zip(cells, ids)]
            if solve(slots):
                return True
    return False


def main():
    LAYOUT_DIR.mkdir(parents=True, exist_ok=True)
    out_levels = []
    for level_id in range(1, 21):
        cells, per_layer = try_level(level_id)
        if cells is None:
            raise SystemExit(f"level {level_id} not solvable")
        pool = pool_for(level_id)
        name = f"level_{level_id:02d}"
        (LAYOUT_DIR / f"{name}.json").write_text(
            json.dumps({"name": name, "cells": cells}, indent=2),
            encoding="utf-8",
        )
        out_levels.append({
            "id": level_id,
            "name": NAMES[level_id - 1],
            "layout_path": f"res://Data/Layouts/{name}.json",
            "difficulty": min(5, 1 + (level_id - 1) // 4),
            "tile_pool": pool,
        })
        print(
            f"level {level_id:2d}: {tiles(level_id):2d} tiles, "
            f"{layers(level_id)} layers, split {per_layer}"
        )
    LEVELS_PATH.write_text(
        json.dumps({"levels": out_levels}, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    print(f"done: {len(out_levels)} levels")


if __name__ == "__main__":
    main()
