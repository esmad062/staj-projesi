extends Control

@onready var sinav_box = $ScrollContainer/VBoxContainer
@onready var SIDEBAR_SCENE = preload("res://GERCEK/side_bar.tscn")
var night_overlay: ColorRect
var is_night_mode = false

func _ready() -> void:
	gece_modu_hazirla()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var sidebar = SIDEBAR_SCENE.instantiate()
	canvas_layer.add_child(sidebar)
	sinav_listesi_olustur()
	
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)
		
	if has_node("Button"):
		$Button.pressed.connect(_on_button_ger_don_pressed)

func gece_modu_hazirla()->void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	night_overlay.color = Color(0, 0,0,0)
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(night_overlay)

	
func sinav_listesi_olustur() -> void:
	for child in sinav_box.get_children():
		child.queue_free()
		
	var simdiki_zaman = Time.get_unix_time_from_system()
	var bir_hafta_saniye = 7*24*60*60 # 7 gün = 604800 saniye
	
	#ders öğrencinin seçimleri arasında değilse atla
	for sinav in GlobalData.sinavlar: 
		var ders_kodu = sinav.get("ders_kodu", " ")
		if not ders_kodu_kayitli_mi(ders_kodu):
			continue
	
		var sinav_tarih_str = sinav.get("tarih", "")
		var sinav_unix_zaman = tarih_str_to_unix(sinav_tarih_str)
		
		if sinav_unix_zaman > 0:
			var fark_saniye = sinav_unix_zaman - simdiki_zaman
			
			if fark_saniye < 0 or fark_saniye > bir_hafta_saniye:
				continue
		
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
		
		var lbl_kod = olustur_label("Ders Kodu: " + str(sinav.get("ders_kodu", "")), Color("0033aa"))
		var lbl_ad = olustur_label("Ders Adı: " + str(sinav.get("ders_adi", "")), Color("0033aa"))
		var lbl_tur = olustur_label("Sınav Türü: " + str(sinav.get("tur", "")), Color("0033aa"))
		var lbl_tarih = olustur_label("Tarih: " + str(sinav.get("tarih", "")) + " - " + str(sinav.get("saat", "")), Color("cc0000"))
		var lbl_derslik = olustur_label("Derslik: " + str(sinav.get("derslik", "")), Color("cc0000"))
		
		vbox_kart.add_child(lbl_kod)
		vbox_kart.add_child(lbl_ad)
		vbox_kart.add_child(lbl_tur)
		vbox_kart.add_child(lbl_tarih)
		vbox_kart.add_child(lbl_derslik)
		
		margin.add_child(vbox_kart)
		panel.add_child(margin)
		
		sinav_box.add_child(panel)

# Esnek kontrol sağlayan fonksiyon
func ders_kodu_kayitli_mi(kod: String) -> bool:
	for ders in GlobalData.secilen_dersler:
		# Hem "kod" hem "ders_kodu" ihtimaline bakıyoruz, büyük/küçük harf duyarlılığını kaldırıyoruz (.to_upper())
		var d_kod = str(ders.get("kod", ders.get("ders_kodu", ""))).to_upper()
		if d_kod == kod.to_upper():
			return true
			
	for ders in GlobalData.alinan_dersler:
		var d_kod = str(ders.get("kod", ders.get("ders_kodu", ""))).to_upper()
		if d_kod == kod.to_upper():
			return true
	
	return false
	
func tarih_str_to_unix(tarih_str: String) -> int:
	var parcalar = tarih_str.split(".")
	if parcalar.size() == 3:
		var gun = parcalar[0].to_int()
		var ay = parcalar[1].to_int()
		var yil = parcalar[2].to_int()
		
		var tarih_dict = {
			"year" : yil,
			"month" : ay, 
			"day" : gun,
			"hour" : 23, # sınav günü
			"minute" : 59
		}
		return Time.get_unix_time_from_datetime_dict(tarih_dict)
	return 0
		
		
func olustur_label(metin: String, renk: Color) -> Label:
	var lbl = Label.new()
	lbl.text = metin
	lbl.add_theme_color_override("font _olor", renk)
	lbl.modulate = renk
	
	lbl.add_theme_font_size_override("font_size", 14)
	return lbl		

func _on_button_ger_don_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/dashboard.tscn")

# Klavyeden basılan tuşları dinleyen ana Godot fonksiyonu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Eğer basılan tuş ESC (Escape) ise:
		if event.keycode == KEY_ESCAPE:
			_on_button_ger_don_pressed()


func _on_gece_gunduz_pressed() -> void:
	is_night_mode =  !is_night_mode
	
	var tween = create_tween()
	
	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33, 0.4)
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)
