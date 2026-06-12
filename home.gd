extends Node2D

# 1. Preload scene HUD-nya ke dalam variabel (ganti path sesuai folder kamu)
const HUD_SCENE = preload("res://hud.tscn") 

func _ready() -> void:
	# 2. Buat instance/kloningan dari scene HUD
	var hud_instance = HUD_SCENE.instantiate()
	
	# 3. Masukkan ke dalam main screen sebagai anak (child node)
	add_child(hud_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
