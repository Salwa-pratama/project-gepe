extends Node

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
	# Perlambat tempo (dan pitch) agar sesuai dengan animasi langkah karakter
	if sfx_jalan:
		sfx_jalan.pitch_scale = 0.45  # Diperlambat signifikan
	if sfx_kotak_terdorong:
		sfx_kotak_terdorong.pitch_scale = 0.55
	if sfx_mendarat:
		sfx_mendarat.pitch_scale = 0.7
	if bgm:
		bgm.volume_db = -10.0 # Kecilkan volume BGM biar agak pelan

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

func play_lompat():
	if sfx_lompat:
		sfx_lompat.play()

func play_mendarat():
	if sfx_mendarat:
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
		sfx_batu_hancur.play()

func play_kecebur_ceren():
	if sfx_kecebur_ceren:
		sfx_kecebur_ceren.play()

# ================================
# SFX (Looping)
# ================================
func play_jalan():
	if sfx_jalan and not sfx_jalan.playing:
		sfx_jalan.play()

func stop_jalan():
	if sfx_jalan:
		sfx_jalan.stop()

func play_kotak_terdorong():
	if sfx_kotak_terdorong and not sfx_kotak_terdorong.playing:
		sfx_kotak_terdorong.play()

func stop_kotak_terdorong():
	if sfx_kotak_terdorong:
		sfx_kotak_terdorong.stop()
