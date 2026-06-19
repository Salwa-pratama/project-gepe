extends Area2D

# Ekspor variabel agar bisa diatur di editor untuk setiap level berbeda
@export_file("*.tscn") var next_scene: String = "res://level_2.tscn"
@export var button_path: NodePath

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_opened = false
var is_unlocked = true # Jika ada tombol, diset false sampai ditekan

func _ready() -> void:
	# Hubungkan sinyal saat tubuh lain masuk ke area pintu
	body_entered.connect(_on_body_entered)
	
	# Cari tombol di level secara otomatis
	var button = null
	if button_path:
		button = get_node_or_null(button_path)
	else:
		# Coba cari node bernama "tombol" sebagai sibling
		button = get_parent().get_node_or_null("tombol")
		
	if button:
		is_unlocked = false
		button.connect("button_pressed", _on_button_pressed)
		button.connect("button_released", _on_button_released)
		# Set animasi awal pintu terkunci/tertutup
		animated_sprite.play("idle_nutup")

func _on_button_pressed() -> void:
	is_unlocked = true
	# Putar animasi membuka pintu secara visual
	if animated_sprite.sprite_frames.has_animation("mbuka"):
		animated_sprite.play("mbuka")

func _on_button_released() -> void:
	is_unlocked = false
	# Putar animasi menutup pintu kembali jika kotak ditarik
	if animated_sprite.sprite_frames.has_animation("nutup"):
		animated_sprite.play("nutup")
	else:
		animated_sprite.play("idle_nutup")

func _on_body_entered(body: Node2D) -> void:
	if not is_unlocked:
		return # Pintu masih terkunci karena tombol belum ditekan!
		
	if is_opened:
		return
		
	# Pastikan yang masuk adalah karakter pemain
	if body is CharacterBody2D:
		is_opened = true
		# Matikan deteksi tabrakan lebih lanjut
		monitoring = false
		
		# Jika pintu sudah dalam keadaan terbuka (karena tombol ditekan), langsung pindah scene
		# Tetapi jika animasi membuka masih berputar, tunggu sampai selesai
		if animated_sprite.is_playing() and animated_sprite.animation == "mbuka":
			animated_sprite.animation_finished.connect(_on_animation_finished)
		else:
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
