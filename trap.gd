extends TileMapLayer

# Fungsi ini akan dipanggil oleh Karakter saat menginjak trap
func hancurkan_blok_trap(titik_sentuh: Vector2):
	if not Global.has_seen_trap_cutscene:
		Global.has_seen_trap_cutscene = true
		_play_trap_cutscene()
		
	# 1. Ubah posisi global (titik sentuh fisik) menjadi koordinat grid Tile
	var cell_pos = local_to_map(to_local(titik_sentuh))
	
	# 2. Cek apakah ada tile di posisi tersebut (jangan bergantung hanya pada custom data, 
	#    karena kadang lupa set custom data di semua tile pilar)
	if get_cell_source_id(cell_pos) != -1:
		_hancurkan_semua_terhubung(cell_pos)

# Algoritma Flood-Fill untuk mencari semua Tile yang menyambung menjadi 1 pilar
func _hancurkan_semua_terhubung(start_cell: Vector2i):
	var sel_yang_dihancurkan = []
	var antrian = [start_cell]
	var sudah_dicek = {}
	
	while antrian.size() > 0:
		var sel_saat_ini = antrian.pop_front()
		
		# Jangan cek sel yang sama dua kali
		if sudah_dicek.has(sel_saat_ini):
			continue
		sudah_dicek[sel_saat_ini] = true
		
		# Cek apakah di posisi tetangga masih ada tile dari layer "trap" ini
		if get_cell_source_id(sel_saat_ini) != -1:
			sel_yang_dihancurkan.append(sel_saat_ini)
			
			# Tambahkan sel di sebelahnya (Atas, Bawah, Kiri, Kanan) ke antrian untuk dicek
			antrian.append(sel_saat_ini + Vector2i(0, -1)) # Atas
			antrian.append(sel_saat_ini + Vector2i(0, 1))  # Bawah
			antrian.append(sel_saat_ini + Vector2i(-1, 0)) # Kiri
			antrian.append(sel_saat_ini + Vector2i(1, 0))  # Kanan
			
	# Setelah mendapatkan seluruh kumpulan kotak penyusun 1 pilar, hancurkan dengan efek!
	for sel in sel_yang_dihancurkan:
		_spawn_efek_jatuh(sel)
		erase_cell(sel)

# Fungsi untuk memunculkan pecahan blok yang jatuh (RigidBody)
func _spawn_efek_jatuh(sel: Vector2i):
	var source_id = get_cell_source_id(sel)
	if source_id == -1: return
	
	var atlas_coords = get_cell_atlas_coords(sel)
	var source = tile_set.get_source(source_id) as TileSetAtlasSource
	
	if source:
		var texture = source.texture
		var region = source.get_tile_texture_region(atlas_coords)
		
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.region_enabled = true
		sprite.region_rect = region
		
		var rb = RigidBody2D.new()
		rb.add_child(sprite)
		rb.global_position = to_global(map_to_local(sel))
		
		# Beri ledakan/dorongan kecil agar puing-puing berhamburan
		rb.linear_velocity = Vector2(randf_range(-60, 60), randf_range(-100, 0))
		rb.angular_velocity = randf_range(-5, 5)
		
		# Matikan collision agar puing tidak menghalangi jalan pemain (jatuh tembus lantai)
		rb.collision_layer = 0
		rb.collision_mask = 0 
		
		get_tree().current_scene.add_child(rb)
		
		# Puing-puing hilang setelah 3 detik
		var timer = get_tree().create_timer(3.0)
		timer.timeout.connect(func(): if is_instance_valid(rb): rb.queue_free())

func _play_trap_cutscene() -> void:
	Global.is_in_cutscene = true
	var char_nodes = get_tree().get_nodes_in_group("player")
	if char_nodes.is_empty(): return
	var karakter = char_nodes[0]
	
	# Tunggu karakternya jatuh dan nyentuh lantai (sekitar 0.8 detik)
	await get_tree().create_timer(0.8).timeout
	
	if "in_cutscene" in karakter:
		karakter.in_cutscene = true
		karakter.cutscene_dir = 0.0
		
	var balloon_scene = load("res://dialogue_ballons/balloon.tscn")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		var resource = load("res://dialogues/main.dialogue")
		balloon.start(resource, "level_1_trap")
		await balloon.tree_exited
		
	if "in_cutscene" in karakter:
		karakter.in_cutscene = false
	Global.is_in_cutscene = false
