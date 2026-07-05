extends Control

@onready var start_btn = $VBoxContainer/start
@onready var option_btn = $VBoxContainer/option
@onready var exit_btn = $VBoxContainer/exit

func _ready() -> void:
	if Global.show_level_selection:
		self.visible = false
		
	# Menyambungkan sinyal klik tombol secara otomatis lewat kode (nggak perlu dicolok manual di editor)
	if start_btn:
		start_btn.pressed.connect(_on_start_pressed)
	if option_btn:
		option_btn.pressed.connect(_on_option_pressed)
	if exit_btn:
		exit_btn.pressed.connect(_on_exit_pressed)

func _on_start_pressed() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_click()
	self.visible = false
	var hud_level = get_node_or_null("../CanvasLayer/hud_level_option")
	if hud_level:
		var canvas = get_node_or_null("../CanvasLayer")
		if canvas:
			canvas.visible = true
		hud_level.visible = true
	else:
		hud_level = get_node_or_null("../hud_level_option")
		if hud_level:
			hud_level.visible = true
		else:
			# Fallback
			get_tree().change_scene_to_file("res://hud_level_option.tscn")

func _on_option_pressed() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_click()
	# Bebas mau diisi apa nanti, sekarang kita print aja dulu
	print("Tombol Option ditekan!")

func _on_exit_pressed() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_click()
	# Keluar dari game
	get_tree().quit()
