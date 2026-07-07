extends CharacterBody2D

# Konstanta gerakan fisika
const SPEED = 250.0
const PUSH_PULL_SPEED = 120.0 # Kecepatan lebih lambat saat membawa kotak
const JUMP_VELOCITY = -500.0

# Referensi ke AnimatedSprite2D untuk mengontrol animasi
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dust_particles: GPUParticles2D = $GPUParticles2D

# Mendapatkan nilai gravitasi default dari Project Settings Godot
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var grabbed_box: CharacterBody2D = null
var can_exit_room: bool = false
var start_pos: Vector2 = Vector2.ZERO

var in_cutscene: bool = false
var cutscene_dir: float = 0.0
var was_on_floor: bool = false

func _ready() -> void:
	add_to_group("player")
	start_pos = global_position
	
	# Setup pengaturan visual efek partikel pasir/debu
	if dust_particles and dust_particles.process_material is ParticleProcessMaterial:
		var mat = dust_particles.process_material as ParticleProcessMaterial
		mat.particle_flag_disable_z = true
		mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		mat.emission_sphere_radius = 4.0
		mat.direction = Vector3(-1, -0.5, 0)
		mat.spread = 25.0
		mat.initial_velocity_min = 20.0
		mat.initial_velocity_max = 50.0
		mat.gravity = Vector3(0, -10, 0)
		mat.scale_min = 4.0
		mat.scale_max = 8.0
		mat.color = Color(0.76, 0.65, 0.45, 0.8) # Warna pasir
		dust_particles.amount = 12
		dust_particles.lifetime = 0.4
		dust_particles.explosiveness = 0.05

func _physics_process(delta: float) -> void:
	# 1. Terapkan Gravitasi jika tidak sedang menyentuh lantai
	if not is_on_floor():
		velocity.y += gravity * delta

	# Cek apakah pemain menekan tombol Shift untuk meraih/mencengkeram kotak
	var is_grabbing := Input.is_key_pressed(KEY_SHIFT)
	
	if not is_grabbing:
		# Lepaskan kotak jika tombol Shift tidak ditekan
		if grabbed_box != null:
			grabbed_box.velocity.x = 0
			grabbed_box = null
	else:
		# Jika menekan Shift dan belum memegang kotak, cari kotak terdekat
		if grabbed_box == null:
			grabbed_box = _get_nearby_box()

	# 2. Tangani Lompatan (Hanya bisa jika tidak sedang memegang kotak)
	if grabbed_box == null:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			if has_node("/root/SoundManager"):
				SoundManager.play_lompat()

	# 3. Tangani Input Arah Gerakan Horizontal (ui_left / ui_right)
	var direction := Input.get_axis("ui_left", "ui_right")
	if in_cutscene:
		direction = cutscene_dir
	
	if grabbed_box != null:
		# --- LOGIKA BERSAMA KOTAK (HOLD SHIFT) ---
		# Selalu hadapkan karakter ke arah kotak yang dipegang
		if grabbed_box.global_position.x < global_position.x:
			animated_sprite.flip_h = true # Hadap kiri
		else:
			animated_sprite.flip_h = false # Hadap kanan
			
		if direction != 0:
			velocity.x = direction * PUSH_PULL_SPEED
			# Salurkan kecepatan gerakan karakter ke kotak
			grabbed_box.velocity.x = velocity.x
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			grabbed_box.velocity.x = 0
	else:
		# --- LOGIKA GERAKAN NORMAL (TANPA SHIFT) ---
		if direction != 0:
			# Cek apakah karakter sedang mendorong kotak secara fisik (bertabrakan horizontal)
			var is_pushing_box := false
			if is_on_floor():
				for i in get_slide_collision_count():
					var collision = get_slide_collision(i)
					var collider = collision.get_collider()
					if collider != null and collider.is_in_group("box") and abs(collision.get_normal().x) > 0.8:
						is_pushing_box = true
						break
			
			if is_pushing_box:
				velocity.x = direction * PUSH_PULL_SPEED
			else:
				velocity.x = direction * SPEED

			# Balikkan arah sprite (flip) sesuai arah gerak
			if direction < 0:
				animated_sprite.flip_h = true
			else:
				animated_sprite.flip_h = false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Tangani Animasi berdasarkan status gerakan & cengkeraman
	_update_animation(direction)

	# 5. Jalankan pergerakan fisik karakter
	move_and_slide()
	
	# 5.1 Cek apakah baru mendarat di lantai dari lompatan/jatuh
	if is_on_floor() and not was_on_floor:
		if has_node("/root/SoundManager"):
			SoundManager.play_mendarat() # Suara hentakan kaki mendarat
			
	was_on_floor = is_on_floor()

	# --- DETEKSI MENGINJAK TRAP ---
	if is_on_floor():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is TileMapLayer and collider.name == "trap":
				if collider.has_method("hancurkan_blok_trap"):
					# Titik sentuh kita paksa turun sedikit ke bawah (arah gravitasi) 
					# biar pasti kena kotak trap yang diinjak, ngga meleset ke samping
					var titik_sentuh = collision.get_position() + Vector2(0, 4)
					collider.hancurkan_blok_trap(titik_sentuh)
					
	# --- DETEKSI TILE OVERLAP (PINTU TANPA COLLISION FISIK) ---
	var pintu_layer = get_parent().get_node_or_null("pintu")
	# Juga cek node bernama "pintu_masuk" jika ada
	if pintu_layer == null:
		pintu_layer = get_parent().get_node_or_null("pintu_masuk")
		
	var is_stepping_on_pintu = false
	if pintu_layer is TileMapLayer:
		var char_pos = pintu_layer.to_local(global_position)
		var cell_pos = pintu_layer.local_to_map(char_pos)
		var tile_data = pintu_layer.get_cell_tile_data(cell_pos)
		if tile_data and tile_data.get_custom_data("pintu"):
			is_stepping_on_pintu = true
			
	if is_stepping_on_pintu:
		if can_exit_room:
			call_deferred("_deferred_return_to_level")
			can_exit_room = false
	else:
		# Jika karakter tidak sedang menginjak tile pintu sama sekali, barulah dia diizinkan masuk kembali
		can_exit_room = true

	# --- LOGIKA MENDORONG TANPA SHIFT (WALK INTO BOX) ---
	if grabbed_box == null:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider != null and collider.is_in_group("box"):
				# Cek jika mendorong secara horizontal dan karakter berada di lantai
				if abs(collision.get_normal().x) > 0.8 and is_on_floor():
					# Dorong kotak dengan kecepatan yang sama dengan karakter agar mulus
					collider.velocity.x = velocity.x
					# Putar animasi dorong
					if animated_sprite.sprite_frames.has_animation("dorong") and is_on_floor():
						animated_sprite.play("dorong")

	# --- KONTROL EFEK DEBU JALAN ---
	if is_on_floor() and abs(velocity.x) > 10.0 and not (in_cutscene and cutscene_dir == 0.0):
		dust_particles.emitting = true
		var facing_dir = 1.0 if not animated_sprite.flip_h else -1.0
		dust_particles.position.x = -12.0 * facing_dir
		if dust_particles.process_material is ParticleProcessMaterial:
			var mat = dust_particles.process_material as ParticleProcessMaterial
			mat.direction = Vector3(-facing_dir, -0.3, 0)
	else:
		dust_particles.emitting = false

	# 6. Update Audio Jalan / Dorong
	_update_audio()

# Fungsi pembantu untuk mencari kotak terdekat, memprioritaskan arah hadap karakter
func _get_nearby_box() -> CharacterBody2D:
	var boxes = get_tree().get_nodes_in_group("box")
	var closest_box: CharacterBody2D = null
	var min_distance := 999999.0
	
	# Arah hadap karakter: -1 jika menghadap kiri (flip_h), 1 jika kanan
	var facing_dir = -1.0 if animated_sprite.flip_h else 1.0
	
	for box in boxes:
		if box is CharacterBody2D:
			var diff_x = box.global_position.x - global_position.x
			var diff_y = abs(global_position.y - box.global_position.y)
			
			# Toleransi vertikal sedikit ditingkatkan menjadi 75.0 agar bisa mendeteksi dari ketinggian berbeda
			if diff_y < 75.0:
				var abs_diff_x = abs(diff_x)
				if abs_diff_x < 95.0:
					# Berikan diskon jarak jika kotak berada di depan arah hadap karakter
					var is_in_front = (diff_x > 0 and facing_dir > 0) or (diff_x < 0 and facing_dir < 0)
					var distance = abs_diff_x
					if is_in_front:
						distance -= 30.0 # Prioritaskan kotak di depan
						
					if distance < min_distance:
						min_distance = distance
						closest_box = box
	return closest_box

func _update_animation(direction: float) -> void:
	if not is_on_floor():
		# Animasi Lompat
		if animated_sprite.sprite_frames.has_animation("lompat"):
			animated_sprite.play("lompat")
	elif grabbed_box != null:
		# Animasi saat memegang kotak (Hold Shift)
		if direction != 0:
			# Cek apakah arah gerak menjauhi posisi kotak (menarik/pull)
			var is_pulling := false
			if grabbed_box.global_position.x < global_position.x and direction > 0:
				is_pulling = true
			elif grabbed_box.global_position.x > global_position.x and direction < 0:
				is_pulling = true
				
			if is_pulling:
				if animated_sprite.sprite_frames.has_animation("narik"):
					animated_sprite.play("narik")
			else:
				if animated_sprite.sprite_frames.has_animation("dorong"):
					animated_sprite.play("dorong")
		else:
			if animated_sprite.sprite_frames.has_animation("idle"):
				animated_sprite.play("idle")
	else:
		# Animasi Normal
		if direction != 0:
			if animated_sprite.sprite_frames.has_animation("jalan"):
				animated_sprite.play("jalan")
		else:
			if animated_sprite.sprite_frames.has_animation("idle"):
				animated_sprite.play("idle")

func _deferred_return_to_level() -> void:
	if Global.saved_level != null:
		var tree = get_tree()
		var current_room = tree.current_scene
		tree.root.remove_child(current_room)
		current_room.queue_free()
		
		tree.root.add_child(Global.saved_level)
		tree.current_scene = Global.saved_level
		Global.saved_level = null

func _update_audio() -> void:
	# Pastikan SoundManager sudah diload dan siap
	if not has_node("/root/SoundManager"):
		return
		
	# Kalau sedang di udara, atau tidak bergerak horizontal, atau dalam cutscene berdiam diri
	if not is_on_floor() or abs(velocity.x) < 1.0 or (in_cutscene and cutscene_dir == 0.0):
		SoundManager.stop_jalan()
		SoundManager.stop_dorong_dan_narik()
		return

	# Mainkan audio berdasarkan animasi saat ini
	if animated_sprite.animation == "jalan":
		SoundManager.play_jalan()
		SoundManager.stop_dorong_dan_narik()
	elif animated_sprite.animation == "dorong" or animated_sprite.animation == "narik":
		SoundManager.play_dorong_dan_narik()
		SoundManager.stop_jalan()
	else:
		SoundManager.stop_jalan()
		SoundManager.stop_dorong_dan_narik()
