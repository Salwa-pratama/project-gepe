extends CharacterBody2D

# Mendapatkan nilai gravitasi default dari Project Settings Godot
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var dust_particles: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	# Daftarkan kotak ke dalam grup "box" agar mudah dideteksi oleh karakter
	add_to_group("box")
	
	if dust_particles:
		var mat = ParticleProcessMaterial.new()
		mat.particle_flag_disable_z = true
		mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		mat.emission_box_extents = Vector3(30.0, 2.0, 1.0) # Seukuran dasar kotak
		mat.direction = Vector3(0, -1, 0) # Tembak debu ke atas
		mat.spread = 15.0
		mat.initial_velocity_min = 10.0
		mat.initial_velocity_max = 25.0
		mat.gravity = Vector3(0, -5, 0)
		mat.scale_min = 3.0
		mat.scale_max = 6.0
		mat.color = Color(0.76, 0.65, 0.45, 0.8) # Warna debu sama dengan karakter
		
		dust_particles.process_material = mat
		dust_particles.amount = 15
		dust_particles.lifetime = 0.5
		dust_particles.explosiveness = 0.05
		
		# Posisikan partikel tepat di tengah bawah kotak
		dust_particles.position = Vector2(-16.5, 21.0)

func _physics_process(delta: float) -> void:
	# Terapkan gravitasi jika kotak melayang / jatuh
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Lakukan pergerakan dan penanganan tabrakan dengan ubin peta / lantai
	move_and_slide()
	
	# --- KONTROL EFEK DEBU KOTAK ---
	if dust_particles:
		if is_on_floor() and abs(velocity.x) > 10.0:
			dust_particles.emitting = true
		else:
			dust_particles.emitting = false

	# Perlambat kecepatan horizontal kotak secara instan jika tidak ada gaya yang mendorong/menarik
	velocity.x = move_toward(velocity.x, 0, 800 * delta)
