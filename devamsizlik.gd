extends Control

@onready var devamsizlik_box = $ScrollContainer/VBoxContainer
@onready var SIDEBAR_SCENE = preload("res://GERCEK/side_bar.tscn") 

var night_overlay: ColorRect
var is_night_mode = false
func _ready() -> void:
	
	if has_node("Button"):
		$Button.pressed.connect(_button_geridon_pressed)
	
	gece_modu_hazirla()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var sidebar = SIDEBAR_SCENE.instantiate()
	canvas_layer.add_child(sidebar)
	
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)
	
	devamsizlik_listesi_olustur()
	
func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	night_overlay.color = Color(0,0,0,0)
	
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(night_overlay)


func devamsizlik_listesi_olustur() -> void:
	# 1. Eski kartları temizle
	for child in devamsizlik_box.get_children():
		child.queue_free()
		
	var aktif_no = str(GlobalData.aktif_ogrenci_no)
	var eklendi_mi: bool = false
		
	# 2. Devamsızlıkları döngüye al
	for veri in GlobalData.devamsizliklar:
		# KURAL 1: Devamsızlık kaydı aktif öğrenciye ait değilse ATLA
		if str(veri.get("ogrenci_no", "")) != aktif_no:
			continue

		var ders_kodu = veri.get("ders_kodu", "")
		
		# KURAL 2: Öğrenci ders seçimi yaptıysa ve bu ders seçilenler arasında yoksa ATLA
		# (Eğer ders seçimi yapılmadıysa veya alınan derslerde yoksa filtrelenebilir)
		if GlobalData.secilen_dersler.size() > 0 and not ders_kodu_kayitli_mi(ders_kodu):
			continue

		eklendi_mi = true

		# HESAPLAMALAR
		var dev_saat: int = veri.get("devamsizlik_saati", 0)
		var top_saat: int = veri.get("toplam_saat", 40)
		var zorunluluk: int = veri.get("zorunluluk_yuzdesi", 80)
		
		var max_hak: int = int(top_saat * ((100.0 - zorunluluk) / 100.0))
		var kalan_hak: int = max_hak - dev_saat
		
		var durum_metni: String = ""
		var durum_renk: Color
		
		if kalan_hak >= 0:
			durum_metni = "Durum: DEVAMLI (Kalan Hak: " + str(kalan_hak) + " Saat)"
			durum_renk = Color("15b13e") # Yeşil
		else:
			durum_metni = "Durum: DEVAMSIZLIKTAN KALDI! (" + str(abs(kalan_hak)) + " Saat Aşıldı)"
			durum_renk = Color("d90429") # Kırmızı

		# KART OLUŞTURMA
		var panel = PanelContainer.new()
		var style = StyleBoxFlat.new()
		style.bg_color = Color("e8eefc")
		style.border_color = Color("7a82b8")
		style.set_border_width_all(2)
		style.set_corner_radius_all(20)
		panel.add_theme_stylebox_override("panel", style)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_top", 15)
		margin.add_theme_constant_override("margin_bottom", 15)
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_right", 20)
		
		var vbox_kart = VBoxContainer.new()
		
		var lbl_kod = olustur_label("Ders Kodu: " + ders_kodu, Color("2b52ff"))
		var lbl_ad = olustur_label("Ders Adı: " + str(veri.get("ders_adi", "")), Color("2b52ff"))
		var lbl_miktar = olustur_label("Devamsızlık Miktarı: " + str(dev_saat) + " / " + str(max_hak) + " Saat", Color("2b52ff"))
		var lbl_zorunluluk = olustur_label("Devam Zorunluluğu: %" + str(zorunluluk), Color("2b52ff"))
		var lbl_durum = olustur_label(durum_metni, durum_renk)
		
		vbox_kart.add_child(lbl_kod)
		vbox_kart.add_child(lbl_ad)
		vbox_kart.add_child(lbl_miktar)
		vbox_kart.add_child(lbl_zorunluluk)
		vbox_kart.add_child(lbl_durum)
		
		margin.add_child(vbox_kart)
		panel.add_child(margin)
		
		devamsizlik_box.add_child(panel)

	# 3. Eğer öğrenciye ait hiçbir devamsızlık kartı basılmadıysa bilgi mesajı göster
	if not eklendi_mi:
		var lbl_bos = olustur_label("Kayıtlı devamsızlık bilgisi bulunamadı.", Color("2b52ff"))
		devamsizlik_box.add_child(lbl_bos)
func ders_kodu_kayitli_mi(kod: String) -> bool:
	for ders in GlobalData.secilen_dersler:
		var d_kod = str(ders.get("kod", ders.get("ders_kodu", ""))).to_upper()
		if d_kod == kod.to_upper():
			return true
	return false

func olustur_label(metin: String, renk: Color) -> Label:
	var lbl = Label.new()
	lbl.text = metin
	lbl.add_theme_color_override("font_color", renk)
	lbl.modulate = renk
	lbl.add_theme_font_size_override("font_size", 14)
	return lbl		

func _button_geridon_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/dashboard.tscn")

# Klavyeden basılan tuşları dinleyen ana Godot fonksiyonu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Eğer basılan tuş ESC (Escape) ise:
		if event.keycode == KEY_ESCAPE:
			_button_geridon_pressed()


func _on_gece_gunduz_pressed() -> void:
	is_night_mode=!is_night_mode
	var tween = create_tween()
	
	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33, 0.4)
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)
