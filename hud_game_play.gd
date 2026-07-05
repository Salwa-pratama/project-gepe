extends Control

@onready var timer_label: Label = $MarginContainer/Control/timer
@onready var keys_label: Label = $MarginContainer/Control/HBoxContainer/Label2

func _ready() -> void:
	Global.timer_running = true
	Global.keys_updated.connect(_on_keys_updated)
	_on_keys_updated(Global.collected_keys)

func _process(delta: float) -> void:
	if Global.timer_running and not Global.is_in_cutscene:
		Global.level_time += delta
		
	if timer_label:
		var minutes = int(Global.level_time) / 60
		var seconds = int(Global.level_time) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]

func _on_keys_updated(total_keys: int) -> void:
	keys_label.text = "x %d" % total_keys
