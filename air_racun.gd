extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if has_node("/root/SoundManager"):
			SoundManager.stop_bgm()
			SoundManager.play_kecebur_ceren()
			SoundManager.play_gameover()
		
		# Hilangkan player agar seakan tenggelam
		body.visible = false
		body.set_physics_process(false)
		
		# Hentikan timer waktu berjalan
		Global.stop_timer()
		
		# Tampilkan layar Game Over 
		var container = get_tree().current_scene.get_node_or_null("container_game_over")
		if container:
			container.visible = true
			var go = container.get_node_or_null("game_over")
			if go:
				go.visible = true
		else:
			# Jika level belum punya container game_over, buat otomatis secara kode
			var canvas = CanvasLayer.new()
			var game_over_scene = load("res://game_over.tscn")
			if game_over_scene:
				var go = game_over_scene.instantiate()
				canvas.add_child(go)
				get_tree().current_scene.add_child(canvas)
	elif body.is_in_group("box"):
		if has_node("/root/SoundManager"):
			SoundManager.play_kecebur_ceren()
		# Biarkan kotak tidak hancur, buat pijakan karakter

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
