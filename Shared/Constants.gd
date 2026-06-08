extends RefCounted
class_name Constants
## Constants: hằng số dùng chung cho toàn bộ project.
## Bao gồm physics layers, group names, signal names, ...

# ===================== Physics Layers =====================
const LAYER_PLAYER: int = 1 << 0       # 1
const LAYER_ENEMY: int = 1 << 1        # 2
const LAYER_GROUND: int = 1 << 2       # 4
const LAYER_INTERACTABLE: int = 1 << 3 # 8
const LAYER_PICKUP: int = 1 << 4       # 16

# ===================== Group Names =====================
const GROUP_PLAYER: StringName = &"player"
const GROUP_ENEMIES: StringName = &"enemies"
const GROUP_PICKUPS: StringName = &"pickups"
const GROUP_HUD: StringName = &"hud"

# ===================== Input Actions =====================
const INPUT_MOVE_LEFT: String = "move_left"
const INPUT_MOVE_RIGHT: String = "move_right"
const INPUT_MOVE_FORWARD: String = "move_forward"
const INPUT_MOVE_BACK: String = "move_back"
const INPUT_JUMP: String = "jump"
const INPUT_PAUSE: String = "pause"

# ===================== Scenes (paths) =====================
const SCENE_BOOT: String = "res://Scenes/Boot/boot.tscn"
const SCENE_MAIN_MENU: String = "res://Scenes/MainMenu/main_menu.tscn"
const SCENE_GAME: String = "res://Scenes/Game/game.tscn"

# ===================== Misc =====================
const MAX_SCORE: int = 999_999
const DEFAULT_GRAVITY: float = 9.8
