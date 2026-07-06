extends Node

# ================================
# SETTING GEMA (REVERB) UNTUK DI DALAM GOA
# Silakan ubah angka-angka di bawah ini lewat Inspector atau langsung di sini
# ================================
@export_group("Pengaturan Gema Goa")
@export var gema_room_size: float = 0.6  # 0.0 - 1.0 (seberapa besar ruangannya)
@export var gema_damping: float = 0.5    # 0.0 - 1.0 (seberapa memantul dindingnya)
@export var gema_wet: float = 0.2        # 0.0 - 1.0 (seberapa tebal efek gemanya)
@export var gema_dry: float = 1.0        # 0.0 - 1.0 (seberapa terdengar suara aslinya)
@export var gema_extra_volume_db: float = 6.0 # Penambah volume (dB) agar gema lebih keras

@onready var bgm = $bgm
@onready var sfx_buka_kunci = $sfx_buka_kunci
@onready var sfx_buka_gerbang = $sfx_buka_gerbang
@onready var sfx_gameover = $sfx_gameover
@onready var sfx_jalan = $sfx_jalan
@onready var sfx_kotak_terdorong = $sfx_kotak_terdorong
@onready var sfx_lompat = $sfx_lompat
@onready var sfx_mendarat = $sfx_mendarat
@onready var sfx_click = $sfx_click
@onready var bgm_luar = $bgm_luar
@onready var sfx_batu_hancur = $sfx_batu_hancur
@onready var sfx_kecebur_ceren = $sfx_kecebur_ceren

# ================================
# Inisialisasi
# ================================
func _ready():
	# Setup bus untuk efek gema (reverb) di dalam goa
	_setup_cave_reverb()
	
	# Perlambat tempo (dan pitch) agar sesuai dengan animasi langkah karakter
	if sfx_jalan:
		sfx_jalan.pitch_scale = 0.45  # Diperlambat signifikan
	if sfx_kotak_terdorong:
		sfx_kotak_terdorong.pitch_scale = 0.55
	if sfx_mendarat:
		sfx_mendarat.pitch_scale = 0.7
	if bgm:
		bgm.volume_db = -10.0 # Kecilkan volume BGM biar agak pelan

func _setup_cave_reverb():
	var bus_name = "CaveReverb"
	if AudioServer.get_bus_index(bus_name) == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		var bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_idx, bus_name)
		
		var reverb = AudioEffectReverb.new()
		reverb.room_size = gema_room_size
		reverb.damping = gema_damping
		reverb.spread = 1.0
		reverb.wet = gema_wet
		reverb.dry = gema_dry
		
		AudioServer.add_bus_effect(bus_idx, reverb)
		AudioServer.set_bus_send(bus_idx, "Master")
		
		# Naikkan volume bus agar suaranya lebih terdengar
		AudioServer.set_bus_volume_db(bus_idx, gema_extra_volume_db)

# ================================
# BGM (Looping)
# ================================
func play_bgm():
	if bgm:
		if not bgm.playing:
			bgm.play()

func stop_bgm():
	if bgm:
		bgm.stop()

func play_bgm_luar():
	if bgm_luar:
		if not bgm_luar.playing:
			bgm_luar.play()

func stop_bgm_luar():
	if bgm_luar:
		bgm_luar.stop()

# ================================
# SFX (Sekali Play)
# ================================
func play_buka_kunci():
	if sfx_buka_kunci:
		sfx_buka_kunci.play()

func play_buka_gerbang():
	if sfx_buka_gerbang:
		sfx_buka_gerbang.play()

func play_gameover():
	if sfx_gameover:
		sfx_gameover.play()

func _update_indoor_reverb(player: AudioStreamPlayer2D):
	if not player: return
	var is_indoor = false
	if get_tree().current_scene:
		var scene_path = get_tree().current_scene.scene_file_path
		if scene_path and scene_path.get_file().begins_with("level_"):
			is_indoor = true
			
	if is_indoor:
		player.bus = "CaveReverb"
	else:
		player.bus = "Master"

func play_lompat():
	if sfx_lompat:
		_update_indoor_reverb(sfx_lompat)
		sfx_lompat.play()

func play_mendarat():
	if sfx_mendarat:
		_update_indoor_reverb(sfx_mendarat)
		sfx_mendarat.play()
		# Hentikan setelah 0.2 detik biar cuma bunyi hentakan sekali (nggak looping panjang)
		await get_tree().create_timer(0.2).timeout
		if sfx_mendarat:
			sfx_mendarat.stop()

func play_click():
	if sfx_click:
		sfx_click.play()

func play_batu_hancur():
	if sfx_batu_hancur:
		_update_indoor_reverb(sfx_batu_hancur)
		sfx_batu_hancur.play()

func play_kecebur_ceren():
	if sfx_kecebur_ceren:
		_update_indoor_reverb(sfx_kecebur_ceren)
		sfx_kecebur_ceren.play()

# ================================
# SFX (Looping)
# ================================
func play_jalan():
	if sfx_jalan and not sfx_jalan.playing:
		_update_indoor_reverb(sfx_jalan)
		sfx_jalan.play()

func stop_jalan():
	if sfx_jalan:
		sfx_jalan.stop()

func play_kotak_terdorong():
	if sfx_kotak_terdorong and not sfx_kotak_terdorong.playing:
		_update_indoor_reverb(sfx_kotak_terdorong)
		sfx_kotak_terdorong.play()

func stop_kotak_terdorong():
	if sfx_kotak_terdorong:
		sfx_kotak_terdorong.stop()
