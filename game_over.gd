extends Control

@onready var try_again_btn = $VBoxContainer/HBoxContainer/try_again
@onready var back_btn = $VBoxContainer/HBoxContainer/back

func _ready() -> void:
	if try_again_btn:
		try_again_btn.pressed.connect(_on_try_again_pressed)
	if back_btn:
		back_btn.pressed.connect(_on_back_pressed)

func _on_try_again_pressed() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_click()
	if has_node("/root/SoundManager"): SoundManager.stop_bgm()
	
	# Reset timer dan status
	Global.reset_level_data()
	
	get_tree().reload_current_scene()

func _on_back_pressed() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_click()
	if has_node("/root/SoundManager"): SoundManager.stop_bgm()
	get_tree().change_scene_to_file("res://Home.tscn")
