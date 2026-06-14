extends Area2D

# Ekspor variabel agar bisa diatur di editor untuk setiap level berbeda
@export_file("*.tscn") var next_scene: String = "res://level_2.tscn"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_opened = false

func _ready() -> void:
	# Hubungkan sinyal saat tubuh lain masuk ke area pintu
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_opened:
		return
		
	# Pastikan yang masuk adalah karakter pemain (memeriksa tipe/nama atau jika memiliki method fisika)
	if body is CharacterBody2D:
		is_opened = true
		# Matikan deteksi tabrakan lebih lanjut
		monitoring = false
		
		# Putar animasi membuka pintu
		if animated_sprite.sprite_frames.has_animation("mbuka"):
			animated_sprite.play("mbuka")
			animated_sprite.animation_finished.connect(_on_animation_finished)
		else:
			# Jika tidak ada animasi, langsung pindah scene
			_change_scene()

func _on_animation_finished() -> void:
	# Putuskan koneksi agar tidak terpanggil berulang
	if animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.disconnect(_on_animation_finished)
	_change_scene()

func _change_scene() -> void:
	if next_scene != "":
		# Berpindah ke level selanjutnya
		get_tree().change_scene_to_file(next_scene)
	else:
		# Jika tidak diset, kembali ke menu utama
		get_tree().change_scene_to_file("res://Home.tscn")
