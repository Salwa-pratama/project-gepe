extends Area2D

func _process(_delta: float) -> void:
	if Global.has_seen_poison_water_dialogue:
		set_process(false)
		return
		
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		
		# Hitung jarak horizontal dan vertikal
		var distance_x = abs(player.global_position.x - global_position.x)
		var distance_y = abs(player.global_position.y - global_position.y)
		
		# Jika pemain cukup dekat dengan air racun (jarak x < 280, jarak y < 150)
		if distance_x < 280.0 and distance_y < 150.0:
			_play_poison_water_dialogue()

func _play_poison_water_dialogue() -> void:
	# Matikan _process agar tidak terpanggil dua kali
	set_process(false)
	Global.has_seen_poison_water_dialogue = true
	
	Global.is_in_cutscene = true
	var chars = get_tree().get_nodes_in_group("player")
	if chars.size() > 0:
		if "in_cutscene" in chars[0]:
			chars[0].in_cutscene = true
			chars[0].cutscene_dir = 0.0
			
	# Diam dulu selama 1.5 detik sebelum dialog muncul
	await get_tree().create_timer(1.5).timeout
			
	var balloon_scene = load("res://dialogue_ballons/balloon.tscn")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		var resource = load("res://dialogues/main.dialogue")
		balloon.start(resource, "poison_water")
		await balloon.tree_exited
		
	if chars.size() > 0:
		if "in_cutscene" in chars[0]:
			chars[0].in_cutscene = false
			
	Global.is_in_cutscene = false
