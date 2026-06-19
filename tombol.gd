extends Area2D

# Sinyal ketika tombol ditekan/dilepas oleh kotak
signal button_pressed
signal button_released

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Menyimpan referensi kotak-kotak yang sedang menekan tombol
var pressing_boxes = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set animasi awal (tidak ditekan)
	animated_sprite.play("none")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("box"):
		if not body in pressing_boxes:
			pressing_boxes.append(body)
			
		# Jika ini kotak pertama yang menekan tombol
		if pressing_boxes.size() == 1:
			# Play animasi ditekan (menggunakan sprite t2.png)
			# Di tombol.tscn, animasi "close" adalah t2 lalu t1, "open" adalah t1 lalu t2, dan "none" adalah t1.
			# Kita akan set frame manual ke t2.png dengan menghentikan animasi di frame 1 dari "open"
			animated_sprite.play("open")
			animated_sprite.frame = 1
			animated_sprite.pause()
			emit_signal("button_pressed")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("box"):
		if body in pressing_boxes:
			pressing_boxes.erase(body)
			
		# Jika tidak ada kotak lagi di atas tombol
		if pressing_boxes.size() == 0:
			# Kembalikan ke visual t1.png
			animated_sprite.play("none")
			emit_signal("button_released")
