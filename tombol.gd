extends Area2D

# Sinyal ketika tombol ditekan/dilepas oleh kotak atau karakter
signal button_pressed
signal button_released

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Menyimpan referensi objek (kotak atau karakter) yang sedang menekan tombol
var pressing_bodies = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set animasi awal (tidak ditekan)
	animated_sprite.play("none")

func _on_body_entered(body: Node2D) -> void:
	# Cek apakah yang masuk adalah kotak ATAU karakter (player)
	if body.is_in_group("box") or body.is_in_group("player"):
		if not body in pressing_bodies:
			pressing_bodies.append(body)
			
		# Pengecekan cutscene dipisah agar tetap jalan meskipun player masih berada di atas tombol
		if body.is_in_group("player") and not Global.has_seen_button_press:
			Global.has_seen_button_press = true
			_play_button_press_cutscene(body)
		elif body.is_in_group("box") and not Global.has_seen_button_box:
			Global.has_seen_button_box = true
			_play_button_box_cutscene()
			
		# Jika ini objek pertama yang menekan tombol (secara mekanik pintu)
		if pressing_bodies.size() == 1:
			# Play animasi ditekan
			animated_sprite.play("open")
			animated_sprite.frame = 1
			animated_sprite.pause()
			emit_signal("button_pressed")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("box") or body.is_in_group("player"):
		if body in pressing_bodies:
			pressing_bodies.erase(body)
			
		# Jika tidak ada objek lagi di atas tombol
		if pressing_bodies.size() == 0:
			# Kembalikan ke visual normal
			animated_sprite.play("none")
			emit_signal("button_released")
			
			if body.is_in_group("player") and not Global.has_seen_button_release:
				Global.has_seen_button_release = true
				_play_button_release_cutscene(body)

func _play_button_press_cutscene(body: Node2D) -> void:
	Global.is_in_cutscene = true
	if "in_cutscene" in body:
		body.in_cutscene = true
		body.cutscene_dir = 0.0
	var balloon_scene = load("res://dialogue_ballons/balloon.tscn")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		var resource = load("res://dialogues/main.dialogue")
		balloon.start(resource, "level_1_button_press")
		await balloon.tree_exited
	if "in_cutscene" in body:
		body.in_cutscene = false
	Global.is_in_cutscene = false

func _play_button_release_cutscene(body: Node2D) -> void:
	Global.is_in_cutscene = true
	if "in_cutscene" in body:
		body.in_cutscene = true
		body.cutscene_dir = 0.0
	var balloon_scene = load("res://dialogue_ballons/balloon.tscn")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		var resource = load("res://dialogues/main.dialogue")
		balloon.start(resource, "level_1_button_release")
		await balloon.tree_exited
	if "in_cutscene" in body:
		body.in_cutscene = false
	Global.is_in_cutscene = false

func _play_button_box_cutscene() -> void:
	Global.is_in_cutscene = true
	var char_nodes = get_tree().get_nodes_in_group("player")
	if char_nodes.is_empty(): return
	var player = char_nodes[0]
	
	if "in_cutscene" in player:
		player.in_cutscene = true
		player.cutscene_dir = 0.0
	var balloon_scene = load("res://dialogue_ballons/balloon.tscn")
	if balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		var resource = load("res://dialogues/main.dialogue")
		balloon.start(resource, "level_1_button_box")
		await balloon.tree_exited
	if "in_cutscene" in player:
		player.in_cutscene = false
	Global.is_in_cutscene = false

