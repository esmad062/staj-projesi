extends Control

var ders_kutusu_sablonu = preload("res://GERCEK/ders_kutusu.tscn")
@onready var vbox = $ScrollContainer/VBoxContainer
@onready var asim_uyarisi = $"AsımUyarisi"
@onready var kredi_label =  $alinanKredi

var _islem_yapiliyor: bool = false # Sinyal döngüsünü engellemek için bayrak (flag)

@onready var SIDEBAR_SCENE = preload("res://GERCEK/side_bar.tscn")

var night_overlay: ColorRect
var is_night_mode = false

func _ready() -> void:
	
	if has_node("Button_kaydet"):
		$Button_kaydet.pressed.connect(_on_button_pressed_kaydet)
	
	if has_node("Button"):
		$Button.pressed.connect(_on_button_pressed_geri)
#	GlobalData.json_verilerini_yukle()
	gece_modu_hazirla()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var sidebar = SIDEBAR_SCENE.instantiate()
	canvas_layer.add_child(sidebar)
	
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)
	
	if asim_uyarisi:
		asim_uyarisi.visible = false
	
	_kredi_guncelle(0.0)
		
	# --- 1. GÜVENLİ TEMİZLİK ---
	for child in vbox.get_children():
		child.queue_free()
				
	# --- 2. KONTROL VE HATA AYIKLAMA ---
	print("Acılan Dersler Dizisi: ", GlobalData.acilan_dersler)
	
	if GlobalData.acilan_dersler.size() == 0:
		print("HATA: GlobalData.acilan_dersler dizisi tamamen boş! JSON yüklenememiş olabilir.")
		return

	# --- 3. DERS KUTULARINI OLUŞTURMA ---
	for ders in GlobalData.acilan_dersler:
		if ders_kutusu_sablonu == null:
			print("HATA: ders_kutusu.tscn şablonu bulunamadı!")
			break
			
		var yeni_kutu = ders_kutusu_sablonu.instantiate()
		yeni_kutu.set_meta("ders_verisi", ders)
		
		var ders_metni = str(ders.get("kod", "")) + " - " + str(ders.get("ad", ""))
		var kredi_verisi = str(ders.get("akts", ""))
		
		# Düğüm isimlerini büyük/küçük harf duyarlılığı için kontrol edelim
		var label_node = yeni_kutu.get_node_or_null("Label")
		var label2_node = yeni_kutu.get_node_or_null("Label2") 
		
		if label_node:
			label_node.text = ders_metni
		if label2_node:
			label2_node.text = "Kredi: " + kredi_verisi
			
		vbox.add_child(yeni_kutu)
		
		var check = _check_box_bul(yeni_kutu)
		if check:
			check.toggled.connect(Callable(self, "_on_checkbox_toggled"))
		else:
			print("UYARI: Kutu içinde CheckBox bulunamadı! Ders: ", ders_metni)
func _check_box_bul(kutu: Node) -> CheckBox:
	var check = kutu.get_node_or_null("HBoxContainer/CheckBox")
	if not check:
		check = kutu.get_node_or_null("CheckBox")
		if not check:
			check = kutu.get_node_or_null("HBoxcontainer/CheckBox")
	return check

func _on_checkbox_toggled(_button_pressed: bool) -> void:
	# Kod kendi kendine CheckBox sıfırlarken tekrar tetiklenmesin
	if _islem_yapiliyor:
		return
		
	var toplam_akts: float = 0.0
	
	# Şu an seçili olan tüm derslerin kredisini topla
	for kutu in vbox.get_children():
		var check = _check_box_bul(kutu)
		if check and check.button_pressed:
			if kutu.has_meta("ders_verisi"):
				var ders = kutu.get_meta("ders_verisi")
				toplam_akts += float(ders.get("akts", 0))

	# 30 AKTS Sınır Kontrolü
	if toplam_akts > 30.0:
		_islem_yapiliyor = true # Otomatik sıfırlama kilidini aç
		
		# 1. Aşım uyarısını açık yap
		if asim_uyarisi:
			asim_uyarisi.visible = true
		
		# 2. Seçilen BÜTÜN CheckBox'ları sıfırla
		for kutu in vbox.get_children():
			var check = _check_box_bul(kutu)
			if check:
				check.button_pressed = false
				
		# 3. Krediyi 0'a çek
		_kredi_guncelle(0.0)
		
		_islem_yapiliyor = false # Kilidi kapat
	else:
		# Sınır aşılmadıysa krediyi güncelle ve uyarıyı kapat
		_kredi_guncelle(toplam_akts)
		if asim_uyarisi:
			asim_uyarisi.visible = false
			asim_uyarisi.text = "30 dan fazla kredi alamazsınız!"

# Toplam krediyi ekrandaki Label'a yazdıran yardımcı fonksiyon
func _kredi_guncelle(toplam: float) -> void:
	if kredi_label:
		kredi_label.text = "Seçilen Kredi: " + str(toplam) + " / 30"

func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	
	night_overlay.set_anchors_preset(PRESET_FULL_RECT)
	night_overlay.color = Color(0,0,0,0)
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(night_overlay)

func _on_button_pressed_geri() -> void:
	get_tree().change_scene_to_file("res://GERCEK/dashboard.tscn")

func _on_button_pressed_kaydet() -> void:
	var secilen_var_mi: bool = false
	var ogr_no = str(GlobalData.aktif_ogrenci_no)
	
	for kutu in vbox.get_children():
		var check = _check_box_bul(kutu)
		if check and check.button_pressed:
			secilen_var_mi = true
			
			if kutu.has_meta("ders_verisi"):
				var ders = kutu.get_meta("ders_verisi").duplicate()
				ders["ogrenci_no"] = ogr_no
				ders["donem"] = "2026-Bahar"
				
				var ders_adi = ders.get("ad", "")
				var ders_kodu = ders.get("kod", "")
				ders["harf_notu"] = GlobalData.ogrenci_ders_notu_getir(ogr_no, ders_adi, ders_kodu)
				
				var zaten_var_mi = false
				for k_ders in GlobalData.alinan_dersler:
					if k_ders.get("ad") == ders_adi and str(k_ders.get("ogrenci_no")) == ogr_no:
						k_ders["harf_notu"] = ders["harf_notu"]
						zaten_var_mi = true
						break
				
				if not zaten_var_mi:
					GlobalData.alinan_dersler.append(ders)
#					GlobalData.verileri_kaydet()
				
	if not secilen_var_mi:
		print("Kaydedilecek en az bir tane ders seçin!")
		return
		
	print("Dersler başarıyla kaydedildi! Kayıtlı Dersler: ", GlobalData.alinan_dersler)
	get_tree().change_scene_to_file("res://GERCEK/Transkript.tscn")

# Klavyeden basılan tuşları dinleyen ana Godot fonksiyonu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Eğer basılan tuş ESC (Escape) ise:
		if event.keycode == KEY_ESCAPE:
			_on_button_pressed_geri() # Geri dön butonunun fonksiyonunu tetikler


func _on_gece_gunduz_pressed() -> void:
	is_night_mode = !is_night_mode
	
	var tween = create_tween()
	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33, 0.4)
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)
