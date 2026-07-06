extends Control

@onready var timer_label: Label = $MarginContainer/Control/timer
@onready var keys_label: Label = $MarginContainer/Control/HBoxContainer/Label2
@onready var pause_btn: Button = $MarginContainer/Control/Button

func _ready() -> void:
	Global.timer_running = true
	Global.keys_updated.connect(_on_keys_updated)
	_on_keys_updated(Global.collected_keys)
	
	if pause_btn:
		pause_btn.pressed.connect(_on_pause_pressed)

func _process(delta: float) -> void:
	if Global.timer_running and not Global.is_in_cutscene:
		Global.level_time += delta
		
	if timer_label:
		var minutes = int(Global.level_time) / 60
		var seconds = int(Global.level_time) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]

func _on_keys_updated(total_keys: int) -> void:
	keys_label.text = "x %d" % total_keys

func _on_pause_pressed() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_click()
	
	# Cari atau buat hud_pause
	var canvas = get_parent()
	if canvas and canvas is CanvasLayer:
		var pause_menu = canvas.get_node_or_null("hud_pause")
		if not pause_menu:
			var pause_scene = load("res://hud_pause.tscn")
			if pause_scene:
				pause_menu = pause_scene.instantiate()
				canvas.add_child(pause_menu)
		
		if pause_menu:
			pause_menu.visible = true
			get_tree().paused = true
