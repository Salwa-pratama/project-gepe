extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if Global.collected_keys == 0:
			if not Global.has_seen_locked_chest:
				_play_locked_cutscene()
		else:
			if not Global.has_opened_chest:
				_play_open_cutscene()

func _play_locked_cutscene() -> void:
	Global.has_seen_locked_chest = true
	Global.is_in_cutscene = true
	
	var chars = get_tree().get_nodes_in_group("player")
	if chars.size() > 0:
		if "in_cutscene" in chars[0]:
			chars[0].in_cutscene = true
			chars[0].cutscene_dir = 0.0
			
	var balloon_scene = load("res://dialogue_ballons/balloon.tscn")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		var resource = load("res://dialogues/main.dialogue")
		balloon.start(resource, "locked_chest")
		await balloon.tree_exited
		
	if chars.size() > 0:
		if "in_cutscene" in chars[0]:
			chars[0].in_cutscene = false
			
	Global.is_in_cutscene = false

func _play_open_cutscene() -> void:
	Global.has_opened_chest = true
	Global.is_in_cutscene = true
	Global.use_key() # Pakai 1 kunci untuk buka peti dan update UI
	
	# Hentikan pergerakan karakter
	var chars = get_tree().get_nodes_in_group("player")
	if chars.size() > 0:
		if "in_cutscene" in chars[0]:
			chars[0].in_cutscene = true
			chars[0].cutscene_dir = 0.0
			
	# Mainkan animasi kebuka pada chest
	var sprite = $AnimatedSprite2D
	if sprite:
		sprite.play("kebuka")
		# Tunggu sampai animasi benar-benar selesai (animasi ini lumayan lama karena speed 1 fps)
		await sprite.animation_finished
		
	# Setelah peti terbuka full, diam termenung sejenak (1.5 detik) buat dapet feel-nya
	await get_tree().create_timer(1.5).timeout
	
	# Munculkan dialog kemenangan
	var balloon_scene = load("res://dialogue_ballons/balloon.tscn")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		var resource = load("res://dialogues/main.dialogue")
		balloon.start(resource, "chest_opened")
		await balloon.tree_exited
		
	# Bebaskan karakter setelah selesai dialog (meski nanti ganti scene, biar aman)
	if chars.size() > 0:
		if "in_cutscene" in chars[0]:
			chars[0].in_cutscene = false
			
	Global.is_in_cutscene = false
	
	# Tamatin gamenya dan buka semua level!
	Global.unlocked_levels = 3
	
	# Pindah ke layar utama (Home)
	get_tree().change_scene_to_file("res://Home.tscn")
