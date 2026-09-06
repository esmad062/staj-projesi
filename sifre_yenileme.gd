extends Control

@onready var ogr_no_input = $VBoxContainer/OgrenciNoInput
@onready var yeni_sifre_input = $VBoxContainer/YeniSifreInput
@onready var tekrar_yeni_sifre = $VBoxContainer/TekrarYeniSifreInput
@onready var hata_mesaji = $VBoxContainer/Hata

var night_overlay: ColorRect
var is_night_mode = false

func _ready() -> void:
	
	if has_node("Button"):
		$Button.pressed.connect(_on_geri_don_pressed)
	
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)
	gece_modu_hazirla()	
	hata_mesaji.text = " " #başlangıçta boş olsun
	
func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	night_overlay.color = Color(0, 0,0 ,0)
	
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(night_overlay)
	
func _on_guncelle_button_pressed() -> void:
	var ogr_no = ogr_no_input.text.strip_edges()
	var yeni_sifre = yeni_sifre_input.text.strip_edges()
	var sifre_tekrar = tekrar_yeni_sifre.text.strip_edges()
	
	if ogr_no == "" or yeni_sifre == "" or sifre_tekrar == "":
		hata_mesaji.add_theme_color_override("font_color", Color.RED)
		hata_mesaji.text = "Lütfen tüm alanları doldurun"
		return
		
	if yeni_sifre != sifre_tekrar:
		hata_mesaji.add_theme_color_override("font_color", Color.RED)
		hata_mesaji.text = "Girdiğiniz yeni şifreler birbiriyle uyuşmuyor"
		return
		
	var ogrenci_bulundu_mu: bool = false
	for ogrenci in GlobalData.ogrenci_verileri:
		if ogrenci.get("numarasi", "") == ogr_no:
			ogrenci["sifre"] = yeni_sifre
			ogrenci_bulundu_mu = true
	if ogrenci_bulundu_mu:
		hata_mesaji.add_theme_color_override("font_color", Color.GREEN)
		hata_mesaji.text = "Şifreniz başarıyla kaydedildi"
		
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://GERCEK/login.tscn")
	
	else: 
		hata_mesaji.add_theme_color_override("font_color", Color.RED)
		hata_mesaji.text = " Bu öğrenci numarasında biri yok"
		
func _on_geri_don_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/login.tscn")

# Klavyeden basılan tuşları dinleyen ana Godot fonksiyonu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Eğer basılan tuş ESC (Escape) ise:
		if event.keycode == KEY_ESCAPE:
			_on_geri_don_pressed()
			
func _on_gece_gunduz_pressed() -> void:
	is_night_mode =!is_night_mode
	var tween = create_tween()
	
	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33, 0.4)
		
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)

func _on_ogrenci_no_input_text_submitted(_new_text: String) -> void:
	$VBoxContainer/YeniSifreInput.grab_focus()

func _on_yeni_sifre_input_text_submitted(_new_text: String) -> void:
	$VBoxContainer/TekrarYeniSifreInput.grab_focus()
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			_on_guncelle_button_pressed()
