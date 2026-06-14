extends CharacterBody2D

# Konstanta gerakan fisika
const SPEED = 250.0
const PUSH_PULL_SPEED = 120.0 # Kecepatan lebih lambat saat membawa kotak
const JUMP_VELOCITY = -450.0

# Referensi ke AnimatedSprite2D untuk mengontrol animasi
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Mendapatkan nilai gravitasi default dari Project Settings Godot
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variabel untuk melacak kotak yang sedang ditarik/didorong
var grabbed_box: CharacterBody2D = null

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

	# 3. Tangani Input Arah Gerakan Horizontal (ui_left / ui_right)
	var direction := Input.get_axis("ui_left", "ui_right")
	
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

	# --- LOGIKA MENDORONG TANPA SHIFT (WALK INTO BOX) ---
	if grabbed_box == null:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider != null and collider.is_in_group("box"):
				# Cek jika mendorong secara horizontal dan karakter berada di lantai
				if abs(collision.get_normal().x) > 0.8 and is_on_floor():
					# Dorong kotak dengan kecepatan tereduksi
					collider.velocity.x = velocity.x * 0.5
					# Putar animasi dorong
					if animated_sprite.sprite_frames.has_animation("dorong") and is_on_floor():
						animated_sprite.play("dorong")

# Fungsi pembantu untuk mencari kotak dalam jangkauan terdekat
func _get_nearby_box() -> CharacterBody2D:
	var boxes = get_tree().get_nodes_in_group("box")
	for box in boxes:
		if box is CharacterBody2D:
			var diff_x = abs(global_position.x - box.global_position.x)
			var diff_y = abs(global_position.y - box.global_position.y)
			# Toleransi jarak horizontal 90.0 piksel dan vertikal 50.0 piksel
			if diff_x < 90.0 and diff_y < 50.0:
				return box
	return null

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
