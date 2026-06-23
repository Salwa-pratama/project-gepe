extends Area2D

const CHAR_SCENE = preload("res://char.tscn")

# Sesuaikan koordinat X dan Y ini untuk posisi pojok kiri bawah lantai Anda
var spawn_position = Vector2(100, 600) 

func _ready() -> void:
	_spawn_player()
	_setup_door()

func _spawn_player() -> void:
	# Mencari karakter di dalam scene
	var player = get_node_or_null("char")
	
	# Jika karakter belum ditambahkan ke scene level_2 secara manual, kita buatkan
	if player == null:
		player = CHAR_SCENE.instantiate()
		player.name = "char"
		add_child(player)
	
	# Letakkan pemain di titik spawn (kiri bawah)
	player.global_position = spawn_position

func _setup_door() -> void:
	# Pastikan node pintu di level_2 Anda bernama "pintu_penjara"
	var door = get_node_or_null("pintu_penjara")
	if door:
		# Atur agar pintu ini menuju ke level 3
		door.next_scene = "res://level3.tscn"
