extends Control

@onready var resume_btn = $VBoxContainer/HBoxContainer/resume
@onready var try_again_btn = $VBoxContainer/HBoxContainer/try_again
@onready var back_btn = $VBoxContainer/HBoxContainer/back

func _ready() -> void:
	if resume_btn:
		resume_btn.pressed.connect(_on_resume_pressed)
	if try_again_btn:
		try_again_btn.pressed.connect(_on_try_again_pressed)
	if back_btn:
		back_btn.pressed.connect(_on_back_pressed)

func _on_resume_pressed() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_click()
	self.visible = false
	get_tree().paused = false

func _on_try_again_pressed() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_click()
	get_tree().paused = false
	Global.reset_level_data()
	
	if get_tree().current_scene:
		Global.reset_cutscenes_for_retry(get_tree().current_scene.name)
		
	get_tree().reload_current_scene()

func _on_back_pressed() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_click()
	get_tree().paused = false
	Global.reset_level_data()
	get_tree().change_scene_to_file("res://Home.tscn")
