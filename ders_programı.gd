extends Control

# Gün ve saat eşleşmeleri 
const GUNLER = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma"]
const SAATLER = [
	"8.55 - 9.40", "9.50 - 10.35", "10.45 - 11.30",
	"11.40 - 12.25", "12.25 - 13.10", "13.20 - 14.15",
	"14.25 - 15.10", "15.20 - 16.05", "16.15 - 17.00"
]

@onready var tablo_grid = $GridContainer

@onready var uyari_label = $uyariLabel

const SIDEBAR_SCENE = preload("res://GERCEK/side_bar.tscn") 

var sidebar_instance: Node = null

var night_overlay: ColorRect
var is_night_mode= false
func _ready() -> void:
	
	if has_node("Button2"):
		$Button2.pressed.connect(_on_button_geripressed)
	
	gece_modu_hazirla()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var sidebar = SIDEBAR_SCENE.instantiate()
	canvas_layer.add_child(sidebar)
	
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)
	
	tablo_grid.add_theme_constant_override("h_separation", 0)
	tablo_grid.add_theme_constant_override("v_separation", 0)
	if ders_donemi_aktif_mi() == false:
		if uyari_label:
			uyari_label.text = "Aktif ders dönemi dışındasınız"
			uyari_label.visible = true
		return
		
	var ogr_dersleri = ogr_derslerini_getir()
	if ogr_dersleri.size() == 0:
		if uyari_label:
			uyari_label.text = "Henüz ders kaydı yapmadınız."
			uyari_label.visible = true
		return
	if uyari_label: uyari_label.visible = false
	ders_programini_yukle()
	
#---	GECE GÜNDÜZ MODUNU OLUŞTURAN KOD
func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	night_overlay.color = Color(0,0,0,0)
	
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(night_overlay)
	
# --- TARİH KONTROL FONKSİYONU ---
func ders_donemi_aktif_mi() -> bool:
	#var bugun = Time.get_date_dict_from_system()
	#var ay = bugun["month"] # mesela şubat 2
	#if ay == 7 or ay == 8:
		#return false # yaz tatili
	return true
		
# --- SADECE GİRİŞ YAPAN ÖĞRENCİNİN DERSLERİNİ GETİR ---
func ogr_derslerini_getir() -> Array:
	var mevcut_ogrenci = str(GlobalData.aktif_ogrenci_no)
	var sonuc = []
	for ders in GlobalData.alinan_dersler:
		if str(ders.get("ogrenci_no", "")) == mevcut_ogrenci:
			sonuc.append(ders)
	return sonuc

func ders_programini_yukle():
	# 1. Eski hücreleri/kartları temizle
	for child in tablo_grid.get_children():
		child.queue_free()
		
	# 2. 45 Adet Boş Hücre Oluştur 9X5
	for i in range(45):
		var hucre = Control.new()
		hucre.custom_minimum_size = Vector2(0, 32)
		hucre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hucre.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tablo_grid.add_child(hucre)

	# 3. SADECE aktif öğrenciye ait dersleri yükle
	var mevcut_ogrenci = str(GlobalData.aktif_ogrenci_no)
	
	for ders in GlobalData.alinan_dersler:
		var ders_ogrenci_no = str(ders.get("ogrenci_no", ""))
		
		# SADECE NUMARALAR BİREBİR EŞİTSE EKLE:
		if ders_ogrenci_no == mevcut_ogrenci:
			var gun_idx = -1
			var ders_gunu = str(ders.get("gun", "")).to_lower()
			for i in range(GUNLER.size()):
				if GUNLER[i].to_lower() == ders_gunu:
					gun_idx = i
					break
			
			var saat_idx = SAATLER.find(ders.get("saat", ""))

			if gun_idx != -1 and saat_idx != -1:
				dersi_hucreye_yerlestir(ders, gun_idx, saat_idx)
func dersi_hucreye_yerlestir(ders_bilgisi: Dictionary, gun_index: int, saat_index: int):
	var ders_adi = ders_bilgisi.get("ad", ders_bilgisi.get("ders_adi", "Ders"))
	var derslik = ders_bilgisi.get("derslik", "")
	
	# 1. Panel/Arka plan kutusu
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT) # Hücrenin içini tamamen kaplasın
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 2. Ders Yazısı
	var ders_label = Label.new()
	ders_label.text = ders_adi + "\n(" + derslik + ")"
	ders_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ders_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ders_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ders_label.add_theme_font_size_override("font_size", 10) # Sığması için puntoyu ufak tutuyoruz
	
	panel.add_child(ders_label)

	# 3. İlgili hücreyi bulup içine ekleme
	var hedef_index = (saat_index * 5) + gun_index
	
	if hedef_index < tablo_grid.get_child_count():
		var hedef_hucre = tablo_grid.get_child(hedef_index)
		
		# Eski içerik varsa temizle
		for c in hedef_hucre.get_children():
			c.queue_free()
			
		hedef_hucre.add_child(panel)

func _on_button_geripressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/dashboard.tscn")

# Klavyeden basılan tuşları dinleyen ana Godot fonksiyonu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Eğer basılan tuş ESC (Escape) ise:
		if event.keycode == KEY_ESCAPE:
			_on_button_geripressed()


func _on_gece_gunduz_pressed() -> void:
	is_night_mode = !is_night_mode
	
	var tween = create_tween()
	
	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33, 0.4)
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)
