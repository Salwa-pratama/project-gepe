extends CharacterBody2D

# Mendapatkan nilai gravitasi default dari Project Settings Godot
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# Daftarkan kotak ke dalam grup "box" agar mudah dideteksi oleh karakter
	add_to_group("box")

func _physics_process(delta: float) -> void:
	# Terapkan gravitasi jika kotak melayang / jatuh
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Lakukan pergerakan dan penanganan tabrakan dengan ubin peta / lantai
	move_and_slide()

	# Perlambat kecepatan horizontal kotak secara instan jika tidak ada gaya yang mendorong/menarik
	velocity.x = move_toward(velocity.x, 0, 800 * delta)
