extends Area2D

@onready var karakter = $karakter
@onready var trap_layer = $trap
@onready var fondasi_layer = $fondasi

var falling_tiles: Array[Sprite2D] = []
var tile_velocities: Array[float] = []

func _ready() -> void:
	if has_node("/root/SoundManager"): SoundManager.play_bgm()
	if not Global.has_seen_level_2_start:
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
		balloon.start(resource, "level_2_start")
		await balloon.tree_exited
		
	if karakter and "in_cutscene" in karakter:
		karakter.in_cutscene = false
		
	Global.has_seen_level_2_start = true
	Global.is_in_cutscene = false

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# 1. Proses tile yang sedang jatuh (efek gravitasi)
	for i in range(falling_tiles.size() - 1, -1, -1):
		var sprite = falling_tiles[i]
		tile_velocities[i] += 1200.0 * delta # Kekuatan gravitasi tile
		sprite.global_position.y += tile_velocities[i] * delta
		
		# Cek apakah tile yang jatuh ini nyentuh fondasi
		# Ambil koordinat sedikit di bawah tengah tile
		var cek_posisi = sprite.global_position + Vector2(0, 8) 
		var fondasi_map_pos = fondasi_layer.local_to_map(fondasi_layer.to_local(cek_posisi))
		
		if fondasi_layer.get_cell_tile_data(fondasi_map_pos) != null:
			# Kalau nabrak lantai fondasi, hapus sprite-nya!
			sprite.queue_free()
			falling_tiles.remove_at(i)
			tile_velocities.remove_at(i)

	# 2. Cek apakah karakter menginjak trap
	if karakter and karakter.is_on_floor():
		var posisi_kaki = karakter.global_position + Vector2(0, 60) 
		var posisi_local_trap = trap_layer.to_local(posisi_kaki)
		var koordinat_tile = trap_layer.local_to_map(posisi_local_trap)
		
		var tile_data = trap_layer.get_cell_tile_data(koordinat_tile)
		
		if tile_data != null:
			var bisa_hancur = tile_data.get_custom_data("hancur")
			
			if bisa_hancur == true:
				# Hapus SEMUA tile trap dan ubah jadi sprite jatuh
				var semua_tile = trap_layer.get_used_cells()
				for cell in semua_tile:
					var data = trap_layer.get_cell_tile_data(cell)
					if data and data.get_custom_data("hancur") == true:
						_spawn_falling_tile(cell)
						trap_layer.erase_cell(cell)

func _spawn_falling_tile(cell: Vector2i) -> void:
	var source_id = trap_layer.get_cell_source_id(cell)
	var atlas_coords = trap_layer.get_cell_atlas_coords(cell)
	var source = trap_layer.tile_set.get_source(source_id) as TileSetAtlasSource
	
	if source:
		# Bikin Sprite2D baru (palsuan tile yang jatuh)
		var sprite = Sprite2D.new()
		sprite.texture = source.texture
		sprite.region_enabled = true
		sprite.region_rect = source.get_tile_texture_region(atlas_coords)
		
		# Samakan posisinya dengan posisi tile asli di dunia
		var pos_local = trap_layer.map_to_local(cell)
		sprite.global_position = trap_layer.to_global(pos_local)
		
		add_child(sprite)
		
		# Masukkan ke dalam daftar untuk diproses gravitasinya
		falling_tiles.append(sprite)
		tile_velocities.append(0.0)
