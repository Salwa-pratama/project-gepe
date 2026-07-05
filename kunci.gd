extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Mainkan animasi jika ada
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		# Tambah jumlah kunci global
		Global.add_key()
		# Hapus objek kunci dari layar
		queue_free()
