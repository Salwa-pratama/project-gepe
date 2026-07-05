extends Control

@onready var lvl1_btn = $HBoxContainer/lvl1
@onready var lvl2_btn = $HBoxContainer/lvl2
@onready var lvl3_btn = $HBoxContainer/lvl3
@onready var back_btn = $back

func _ready() -> void:
	# Tampilkan atau sembunyikan sesuai flag Global saat berada di dalam scene Home
	if get_tree().current_scene and (get_tree().current_scene.name == "Node2D" or get_tree().current_scene.name == "Home"):
		if Global.show_level_selection:
			var parent = get_parent()
			if parent and parent is CanvasLayer:
				parent.visible = true
			self.visible = true
		else:
			self.visible = false

	# Hubungkan sinyal tombol ke fungsi
	lvl1_btn.pressed.connect(func(): _load_level(1))
	lvl2_btn.pressed.connect(func(): _load_level(2))
	lvl3_btn.pressed.connect(func(): _load_level(3))
	back_btn.pressed.connect(_on_back_pressed)
	
	# Update tampilan tombol berdasarkan level yang sudah terbuka
	_update_buttons()

func _update_buttons() -> void:
	var buttons = [lvl1_btn, lvl2_btn, lvl3_btn]
	for i in range(buttons.size()):
		var level_num = i + 1
		if level_num <= Global.unlocked_levels:
			buttons[i].disabled = false
			buttons[i].modulate = Color(1, 1, 1, 1) # Warna normal (coklat)
		else:
			buttons[i].disabled = true
			buttons[i].modulate = Color(0.3, 0.3, 0.3, 1) # Warna abu-abu (terkunci)

func _load_level(level_num: int) -> void:
	if level_num == 1 and not Global.has_seen_intro and get_tree().current_scene and (get_tree().current_scene.name == "Node2D" or get_tree().current_scene.name == "Home"):
		_play_level_1_cutscene()
	else:
		_finish_load_level(level_num)

func _finish_load_level(level_num: int) -> void:
	Global.show_level_selection = false
	Global.saved_level = null
	Global.reset_level_data()
	get_tree().change_scene_to_file("res://level_" + str(level_num) + ".tscn")

func _play_level_1_cutscene() -> void:
	Global.is_in_cutscene = true
	# Sembunyikan UI Level Option dan Canvas Layer-nya
	self.visible = false
	var parent_canvas = get_parent()
	if parent_canvas and parent_canvas is CanvasLayer:
		parent_canvas.visible = false
		
	# Cari karakter menggunakan group "player"
	var char_node: CharacterBody2D = null
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		char_node = players[0]
		
	if not char_node:
		_finish_load_level(1)
		return
		
	# Aktifkan mode cutscene di karakter (sehingga fisika & animasi berjalan normal)
	if "in_cutscene" in char_node:
		char_node.in_cutscene = true
		char_node.cutscene_dir = 0.4 # Jalan ke kanan dengan kecepatan 40% (pelan)
	
	# Jalan ke depan sedikit (Phase 1) - biarkan fisika yang mengurus
	await get_tree().create_timer(1.2).timeout
	
	if "cutscene_dir" in char_node:
		char_node.cutscene_dir = 0.0 # Berhenti
		
	# Delay sesaat agar terkesan karakter diam dulu sebelum ngomong
	await get_tree().create_timer(0.8).timeout
	
	# Munculkan Dialog 1
	var balloon_scene = load("res://dialogue_ballons/balloon.tscn")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		var resource = load("res://dialogues/main.dialogue")
		balloon.start(resource, "level_1_intro")
		# Tunggu sampai dialog selesai dan balon dihapus dari tree
		await balloon.tree_exited
		
	# Jalan ke arah pamflet (Phase 2)
	if "cutscene_dir" in char_node:
		char_node.cutscene_dir = 0.5 # Jalan sedang
	
	# Tunggu sampai karakter mendekati pamflet goa (koordinat X sekitar 840)
	var timeout = 8.0
	while char_node.global_position.x < 840 and timeout > 0:
		await get_tree().process_frame
		timeout -= get_process_delta_time()
		
	# Berhenti untuk membaca pamflet
	if "cutscene_dir" in char_node:
		char_node.cutscene_dir = 0.0
		
	# Delay agar terkesan karakternya mengamati pamflet dulu
	await get_tree().create_timer(1.0).timeout
		
	# Munculkan Dialog 2 (Membaca pamflet)
	if balloon_scene:
		var balloon2 = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon2)
		var resource = load("res://dialogues/main.dialogue")
		balloon2.start(resource, "level_1_pamflet")
		await balloon2.tree_exited

	# Lanjut masuk ke dalam goa (Phase 3)
	if "cutscene_dir" in char_node:
		char_node.cutscene_dir = 0.6
		
	# Tunggu sampai karakter mendekati pintu goa (koordinat X sekitar 980)
	timeout = 4.0
	while char_node.global_position.x < 980 and timeout > 0:
		await get_tree().process_frame
		timeout -= get_process_delta_time()
	
	# Selesai, kembalikan kontrol ke pemain
	if "in_cutscene" in char_node:
		char_node.in_cutscene = false
		char_node.cutscene_dir = 0.0
		
	Global.has_seen_intro = true
	Global.is_in_cutscene = false
	_finish_load_level(1)

func _on_back_pressed() -> void:
	Global.show_level_selection = false
	self.visible = false
	var main_hud = get_node_or_null("../../hud")
	if not main_hud:
		main_hud = get_node_or_null("../hud")
		
	if main_hud:
		main_hud.visible = true
	else:
		get_tree().change_scene_to_file("res://Home.tscn")
