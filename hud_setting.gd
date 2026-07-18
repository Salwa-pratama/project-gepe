extends Control

@onready var slider_volume = $container_setting/slider_volume
@onready var label_value = $container_setting/label_value
@onready var back_btn = $back

func _ready() -> void:
	# Hubungkan sinyal
	if slider_volume:
		slider_volume.value_changed.connect(_on_slider_volume_changed)
		# Set nilai slider ke volume master saat ini
		var master_bus = AudioServer.get_bus_index("Master")
		var db_vol = AudioServer.get_bus_volume_db(master_bus)
		# Convert db ke linear (0 - 1) lalu ke scale slider (0 - 100)
		slider_volume.value = db_to_linear(db_vol) * 100.0
		if label_value:
			label_value.text = str(round(slider_volume.value))
		
	if back_btn:
		back_btn.pressed.connect(_on_back_pressed)

func _on_slider_volume_changed(value: float) -> void:
	if has_node("/root/SoundManager"):
		SoundManager.play_click()
	
	var master_bus = AudioServer.get_bus_index("Master")
	# Convert scale slider (0 - 100) ke linear (0 - 1) lalu ke db
	var linear_vol = value / 100.0
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(linear_vol))
	
	if label_value:
		label_value.text = str(round(value))

func _on_back_pressed() -> void:
	if has_node("/root/SoundManager"):
		SoundManager.play_click()
	
	# Sembunyikan hud ini
	self.visible = false
	
	# Kembalikan ke menu utama (hud_menu)
	var parent = get_parent()
	if parent:
		var menu = parent.get_node_or_null("VBoxContainer") # ini struktur dari hud_menu
		if menu:
			parent.visible = true
		else:
			# Jika diinstantiate di CanvasLayer yang punya hud_menu, kita cari
			for child in parent.get_children():
				if child.name == "hud" or child.has_method("_on_option_pressed"):
					child.visible = true
