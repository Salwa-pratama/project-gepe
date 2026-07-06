extends Node

signal keys_updated(total_keys: int)
signal time_updated(time_str: String)

var unlocked_levels: int = 1
var saved_level: Node = null
var show_level_selection: bool = false
var has_seen_intro: bool = false
var has_seen_level_1_start: bool = false
var has_seen_trap_cutscene: bool = false
var has_seen_button_press: bool = false
var has_seen_button_release: bool = false
var has_seen_button_box: bool = false
var has_seen_level_2_start: bool = false
var has_seen_level_3_start: bool = false
var has_seen_ruang_kunci_start: bool = false
var has_seen_locked_chest: bool = false
var has_opened_chest: bool = false
var has_seen_poison_water_dialogue: bool = false
var is_in_cutscene: bool = false

var collected_keys: int = 0
var level_time: float = 0.0
var timer_running: bool = false

func reset_level_data() -> void:
	collected_keys = 0
	level_time = 0.0
	timer_running = true
	keys_updated.emit(collected_keys)
	_update_time_display()

func reset_cutscenes_for_retry(scene_name: String) -> void:
	if scene_name == "level_1" or scene_name == "Node2D2":
		has_seen_level_1_start = false
		has_seen_trap_cutscene = false
		has_seen_button_press = false
		has_seen_button_release = false
		has_seen_button_box = false
		has_seen_poison_water_dialogue = false
	elif scene_name == "level_2":
		has_seen_level_2_start = false
		has_seen_poison_water_dialogue = false
	elif scene_name == "level_3":
		has_seen_level_3_start = false
		has_seen_poison_water_dialogue = false
	elif scene_name == "ruang_kunci":
		has_seen_ruang_kunci_start = false
		has_seen_locked_chest = false
		has_opened_chest = false
		has_seen_poison_water_dialogue = false


func add_key() -> void:
	collected_keys += 1
	keys_updated.emit(collected_keys)

func use_key() -> void:
	if collected_keys > 0:
		collected_keys -= 1
		keys_updated.emit(collected_keys)

func stop_timer() -> void:
	timer_running = false

func _update_time_display() -> void:
	var minutes = int(level_time) / 60
	var seconds = int(level_time) % 60
	var time_str = "%02d:%02d" % [minutes, seconds]
	time_updated.emit(time_str)
