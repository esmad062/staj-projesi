extends Control

@onready var vize_input = $Panel2/Vize
@onready var final_input = $Panel2/Final
@onready var gosterme_label = $Panel2/sonuc
@onready var uyari_label = $Panel2/Uyari
@onready var harf_denk = $Panel2/HarfDenki

@onready var SIDEBAR_SCENE = preload("res://GERCEK/side_bar.tscn")

var night_overlay: ColorRect
var is_night_mode = false
func _ready() -> void:
	if has_node("Button"):
		$Button.pressed.connect(_on_geridon_pressed)
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)
	gece_modu_hazirla()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var sidebar = SIDEBAR_SCENE.instantiate()
	canvas_layer.add_child(sidebar)
	
	gosterme_label.text = "Sonuç: -"

func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	night_overlay.color = Color(0,0,0,0)
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(night_overlay)

# Klavye tuşlarını dinleyen fonksiyon
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# ESC tuşuna basılırsa geri dön
		if event.keycode == KEY_ESCAPE:
			_on_geridon_pressed()
			
		# ENTER veya Numpad ENTER tuşuna basılırsa hesapla
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_on_hesapla_pressed()

# Hesaplama fonksiyonu
func _on_hesapla_pressed() -> void:
	# Kutuların boş kalma durumuna karşı kontrol (Hata almamak için)
	if vize_input.text.is_empty() or final_input.text.is_empty():
		gosterme_label.text = "Lütfen notları girin!"
		gosterme_label.add_theme_color_override("font_color", Color.RED)
		gosterme_label.add_theme_font_size_override("font_size", 20)
		return
		
	var vize: float = float(vize_input.text)
	var final: float = float(final_input.text)
	
	if vize > 100.0 or  final > 100.0 or vize < 0.0 or final < 0.0:
		uyari_label.text = "Girilen Notlar 0 ile 100 Arasında Olmalıdır!"
		uyari_label.add_theme_color_override("font_color", Color.CRIMSON)
		uyari_label.add_theme_font_size_override("font_size", 20)
		return
	
	var sonuc: float = (vize * 0.4) + (final * 0.6)
	harf_denk.add_theme_color_override("font_color", Color.DARK_BLUE)
	if sonuc > 90:
		harf_denk.text = "Harf Notu:"+ "AA"
	elif sonuc > 80:
		harf_denk.text = "Harf Notu:"+"BA"
	elif sonuc > 75:
		harf_denk.text = "Harf Notu:" + "BB"
	elif sonuc > 70:
		harf_denk.text ="Harf Notu:" + "CB"
	elif sonuc > 60:
		harf_denk.text = "Harf Notu:" + "CC"
	elif sonuc > 50:
		harf_denk.text = "Harf Notu:"+"DC"
	elif sonuc > 40:
		harf_denk.text ="Harf Notu:"  +  "DD"
	else:
		harf_denk.text = "Harf Notu:"+"FF"
	
	var my_color = Color.from_string("8A2BE2", Color.BLUE_VIOLET)
	gosterme_label.add_theme_color_override("font_color", my_color)
	#gosterme_label.add_theme_color_override("font_color", Color(0X9E59B9))
	gosterme_label.add_theme_font_size_override("font_size", 20)
	gosterme_label.text = "Sonuç: " + str(snapped(sonuc, 0.01))

# Geri dön fonksiyonu
func _on_geridon_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/dashboard.tscn")


func _on_vize_text_submitted(_new_text: String) -> void:
	$Panel2/Final.grab_focus()
	
func _on_final_text_submitted(_new_text: String) -> void:
	_on_hesapla_pressed()

func _on_gece_gunduz_pressed() -> void:
	is_night_mode =!is_night_mode
	var tween = create_tween()
	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33,0.4)	
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)
