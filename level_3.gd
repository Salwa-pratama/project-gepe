extends Area2D

@onready var karakter = $karakter
@onready var trap_layer = $trap
@onready var fondasi_layer = $fondasi

var tile_velocities: Array[float] = []

func _ready() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_bgm()
	if not Global.has_seen_level_3_start:
		_play_start_cutscene()

func _play_start_cutscene() -> void:
	Global.is_in_cutscene = true
	if karakter and "in_cutscene" in karakter:
		karakter.in_cutscene = true
		karakter.cutscene_dir = 0.3 # Suruh jalan ke kanan PELAN BANGET
		
		# Tunggu sampai sampai di ujung pinggir (jalan pelan butuh waktu lebih lama, sekitar 1.5 detik)
		await get_tree().create_timer(1.5).timeout
		
		karakter.cutscene_dir = 0.0 # Berhenti
		
		# Diam lumayan lama (1 detik) buat nikmatin suasana sebelum munculin dialog
		await get_tree().create_timer(1.0).timeout
	else:
		await get_tree().create_timer(1.0).timeout
		
	# Munculkan Dialog
	var balloon_scene = load("res://dialogue_ballons/balloon.tscn")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		var resource = load("res://dialogues/main.dialogue")
		balloon.start(resource, "level_3_start")
		await balloon.tree_exited
		
	if karakter and "in_cutscene" in karakter:
		karakter.in_cutscene = false
		
	Global.has_seen_level_3_start = true
	Global.is_in_cutscene = false

func _process(_delta: float) -> void:
	pass
