extends Area2D

# Referensi ke tombol-tombol di HUD
@onready var start_button: TextureButton = $CanvasLayer/VBoxContainer/Start
@onready var settings_button: TextureButton = $CanvasLayer/VBoxContainer/Settings
@onready var exit_button: TextureButton = $CanvasLayer/VBoxContainer/Exit

func _ready() -> void:
	# Hubungkan sinyal klik tombol ke fungsinya masing-masing
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_start_pressed() -> void:
	# Mulai game dengan memindahkan scene ke level 1
	get_tree().change_scene_to_file("res://level_1.tscn")

func _on_settings_pressed() -> void:
	# Logika pengaturan bisa ditambahkan di sini nantinya
	print("Tombol Settings ditekan")

func _on_exit_pressed() -> void:
	# Keluar dari game
	get_tree().quit()
