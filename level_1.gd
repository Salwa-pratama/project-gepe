extends Area2D

@onready var karakter = $Node2D
@onready var trap_layer = $trap
@onready var fondasi_layer = $fondasi

var falling_tiles: Array[Sprite2D] = []
var tile_velocities: Array[float] = []

func _ready() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_bgm()
	if not Global.has_seen_level_1_start:
		_play_start_cutscene()

func _play_start_cutscene() -> void:
	Global.is_in_cutscene = true
	if karakter and "in_cutscene" in karakter:
		karakter.in_cutscene = true
		karakter.cutscene_dir = 0.0 # Pastikan diam
		
	# Delay sesaat pas baru masuk level
	await get_tree().create_timer(1.0).timeout
		
	# Munculkan Dialog
	var balloon_scene = load("res://dialogue_ballons/balloon.tscn")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		var resource = load("res://dialogues/main.dialogue")
		balloon.start(resource, "level_1_start")
		await balloon.tree_exited
		
	if karakter and "in_cutscene" in karakter:
		karakter.in_cutscene = false
		
	Global.has_seen_level_1_start = true
	Global.is_in_cutscene = false

func _process(_delta: float) -> void:
	pass
