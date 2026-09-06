extends Control

@onready var OgrNo = $Rectangle15/OGRNoSbt
@onready var DersinKredisi = $Rectangle15/Kredisi
@onready var OgrNumarasi = $Rectangle15/Numarasi
@onready var vbox = $ScrollContainer/VBoxContainer
@onready var hataMesaji = $Uyari
@onready var DönemlikKredi = $Rectangle15/DKGostergesi
@onready var secilen_kredi = $Rectangle15/toplamSecilenKrediSbt
@onready var ganoGostergesi = $Rectangle15/gNO
@onready var SIDEBAR_SCENE = preload("res://GERCEK/side_bar.tscn")

var bilgi_kutusu = preload("res://GERCEK/bilgi_kutucuklari.tscn")

var night_overlay: ColorRect
var is_night_mode = false

func _ready() -> void:
	
	if has_node("Button2"):
		$Button2.pressed.connect(_on_indir_pressed)
	
	gece_modu_hazirla()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	if has_node("Button"):
		$Button.pressed.connect(_on_geridon_pressed)
	
	var sidebar = SIDEBAR_SCENE.instantiate()
	canvas_layer.add_child(sidebar)
	if GlobalData.alinan_dersler.size() == 0:
		if hataMesaji: hataMesaji.text = "Henüz kayıtlı ders bulunmamaktadır."
	
	if GlobalData.aktif_kullanici and GlobalData.aktif_kullanici.has("ogrenci_no"):
		OgrNumarasi.text = str(GlobalData.aktif_kullanici["ogrenci_no"])
		transkripti_yukle()
	
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)

func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	night_overlay.color = Color(0,0,0,0)
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(night_overlay)

func transkripti_yukle() -> void:
	for child in vbox.get_children():
		child.queue_free()
	
	var toplam_akts: float = 0.0
	var donem_kredisi: float = 0.0
	var aktif_donem: String = "2026-Bahar"
	
	for ders in GlobalData.alinan_dersler:
		if str(ders.get("ogrenci_no", "")) != str(GlobalData.aktif_ogrenci_no):
			continue
			
		var yeni_kutucuk = bilgi_kutusu.instantiate()
		vbox.add_child(yeni_kutucuk)
	
		var d_adi = yeni_kutucuk.get_node_or_null("Panel/DAdi")
		var d_kredi = yeni_kutucuk.get_node_or_null("Panel/Kredisi")
		var d_hnotu = yeni_kutucuk.get_node_or_null("Panel/HNotu")
	
		if d_adi: 
			d_adi.text = "Ders adı: " + str(ders.get("ad", ""))
			d_adi.add_theme_color_override("font_color", Color(0, 0, 0))
		
		if d_kredi: 
			d_kredi.text = "Kredi: " + str(ders.get("akts", "0"))
			d_kredi.add_theme_color_override("font_color", Color(0, 0, 0))
			
		if d_hnotu: 
			d_hnotu.text = "Notu: " + str(ders.get("harf_notu", "AA"))
			d_hnotu.add_theme_color_override("font_color", Color(0, 0, 0))
		
		var akts_degeri = float(str(ders.get("akts", 0)).replace(",", "."))
		var ders_donemi = str(ders.get("donem", ders.get("Dönem", "")))
		
		if ders_donemi == aktif_donem:
			donem_kredisi += akts_degeri
				
		toplam_akts += akts_degeri
	
	DersinKredisi.text = "%.2f" % toplam_akts
	DönemlikKredi.text = "%.2f" % donem_kredisi
	
	GlobalData.gano_hesapla()
	ganoGostergesi.text = "%.2f" % GlobalData.gano

func _on_geridon_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/dashboard.tscn")

func _on_indir_pressed() -> void:
	print("Dosya indirildi")

# Klavyeden basılan tuşları dinleyen ana Godot fonksiyonu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Eğer basılan tuş ESC (Escape) ise:
		if event.keycode == KEY_ESCAPE:
			_on_geridon_pressed()


func _on_gece_gunduz_pressed() -> void:
	is_night_mode = !is_night_mode
	
	var tween = create_tween()
	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33, 0.4)
		
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)
