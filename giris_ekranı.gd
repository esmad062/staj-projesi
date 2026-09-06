extends Control

@onready var sifre = $Sifre
@onready var numarasi = $OgrenciNumarasi
@onready var hata_mesaji = $hataMesaji

# Öğrenci numarası ve şifre verileri
var ogrenci_verileri = {
	"101": "12", # Ahmet
	"102": "13",  # Zeynep
	"103": "14",  # Hasan
	"104": "15",  # Esma Gül
	"105" : "16"  # Burhan
}

var night_overlay: ColorRect
var is_night_mode = false

func _ready() -> void:    
	if has_node("giris_butonu"):
		$giris_butonu.pressed.connect(_on_giris_pressed)

	gece_modu_hazirla()
	hata_mesaji.text = ""
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)

func _on_giris_pressed() -> void:
	var numarasi_input = numarasi.text.strip_edges()
	var sifre_input = sifre.text.strip_edges()

	# 1. Alanların boş kontrolü
	if numarasi_input == "" or sifre_input == "":
		hata_mesaji.text = "Lütfen tüm alanları doldurun!"
		hata_mesaji.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		return

	# 2. Şifre ve Numara Doğrulaması
	if ogrenci_verileri.has(numarasi_input) and ogrenci_verileri[numarasi_input] == sifre_input:
		hata_mesaji.text = "" # Hata mesajını temizle
		
		# Animasyonu tetikle ve bitmesini bekle
		if has_node("giris_butonu"):
			await $giris_butonu.giris_animasyonunu_calistir()
		
		# İlgili kullanıcının profilini GlobalData'dan buluyoruz
		var giris_yapan_kullanici = GlobalData.kullanici_bul_by_id(numarasi_input)
		
		if giris_yapan_kullanici != null:
			GlobalData.kullanici_girisi_yap(giris_yapan_kullanici)
		else:
			GlobalData.aktif_ogrenci_no = numarasi_input

		GlobalData.ogrenci_numarasi = numarasi_input

		# Animasyon bittikten hemen sonra dashboard'a geç
		get_tree().change_scene_to_file("res://GERCEK/dashboard.tscn")
		
	else:
		hata_mesaji.text = "Öğrenci numarası veya şifre hatalı!"
		hata_mesaji.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))

func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	night_overlay.color = Color(0, 0, 0, 0)
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(night_overlay)

func _on_sifremi_unuttum_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/sifre_yenileme.tscn")

func _on_ogrenci_numarasi_text_submitted(_new_text: String) -> void:
	$Sifre.grab_focus()

func _on_sifre_text_submitted(_new_text: String) -> void:
	_on_giris_pressed()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _on_gece_gunduz_pressed() -> void:
	is_night_mode = !is_night_mode
	var tween = create_tween()
	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33, 0.4)
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)
