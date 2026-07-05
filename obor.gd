extends Node2D

var time_passed = 0.0
# Atur sesukamu, semakin besar angkanya semakin lambat kedap-kedipnya (misal 0.15 detik)
var change_interval = 0.15


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	if time_passed >= change_interval:
		time_passed = 0.0
		# Ganti energinya secara acak setelah jeda waktu terpenuhi
		$PointLight2D.energy = randf_range(0.85, 1.15)
	pass
