extends Control

@onready var borc_label = $MainContent/LeftPanel/Miktar
@onready var pay_button = $MainContent/RightPanel/PayButton
@onready var ogrenciBilgisi = $MainContent/LeftPanel/OgrenciBilgisi
@onready var sonOdeme = $MainContent/LeftPanel/SonOdeme
@onready var iban = $MainContent/LeftPanel/Iban
@onready var warnin_label = $MainContent/RightPanel/WarningLabel
@onready var name_input = $MainContent/RightPanel/NameInput
@onready var card_input = $MainContent/RightPanel/CardNumInput
@onready var exp_input = $MainContent/RightPanel/expAndCvcBox/ExpInput
@onready var cvc_input = $MainContent/RightPanel/expAndCvcBox/CvcInput

@onready var kart_sahnesi = $MainContent/Control

@onready var SIDEBAR_SCENE = preload("res://GERCEK/side_bar.tscn")

var night_overlay: ColorRect
var is_night_mode = false

func _ready() -> void:
	
	name_input.text_changed.connect(kart_sahnesi.update_name)
	exp_input.text_changed.connect(kart_sahnesi.update_date)
	card_input.text_changed.connect(kart_sahnesi.update_number)
	cvc_input.text_changed.connect(kart_sahnesi.update_cvv)
	
	if has_node("Button"):
		$Button.pressed.connect(_on_button_geri_pressed)
	
	gece_modu_hazirla()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var sidebar = SIDEBAR_SCENE.instantiate()
	canvas_layer.add_child(sidebar)
	
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)
	
	borc_bilgisini_guncelle()
	for kisi in GlobalData.odemeBilgileri:
		if kisi.ogrenci_no == GlobalData.aktif_ogrenci_no:
			borc_label.text = "Toplam Borç:" + "	" + kisi["miktar"]
			ogrenciBilgisi.text = "Öğrenci Numarası:" + "	" + kisi["ogrenci_no"]
			sonOdeme.text = "Son Ödeme Tarihi:" + "	" + kisi["son_odeme"]
			
func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	night_overlay.color = Color(0,0,0,0)
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(night_overlay) 
		
func borc_bilgisini_guncelle():
	if GlobalData.borc_odendi_mi or GlobalData.harc_borcu <= 0:
		borc_label.text = "Toplam Borç: 0.00TL (Harç borcunuz yoktur)"
		pay_button.disabled = true # buton ödediyse pasif olsun 
	else:
		borc_label.text = "Toplam borç:" + "	" + str(GlobalData.harc_borcu) + "TL"
		pay_button.disabled = false #geri aç
			# pay_button.text = str(GlobalData.harc_borcu) + "TL öde"

func _on_button_geri_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/ogrenci_islemleri.tscn")


func _on_pay_button_pressed() -> void:
	var isim = name_input.text.strip_edges() #boşlukları temizler
	var kart_no = card_input.text.strip_edges()
	var exp_date = exp_input.text.strip_edges()
	var cvc = cvc_input.text.strip_edges()
	
	if isim == "" or kart_no == "" or exp_date == "" or cvc == "":
		warnin_label.add_theme_color_override("font_color", Color.RED)
		warnin_label.text = "Lütfen tüm alanları doldurunuz!"
		return
		
	if kart_no in GlobalData.gecerli_kartlar:
		warnin_label.add_theme_color_override("font_color", Color.GREEN)
		warnin_label.text = "ödeme başarılı"
		GlobalData.harc_borcu = 0.0
		GlobalData.borc_odendi_mi = true
		borc_bilgisini_guncelle()
	else:
		warnin_label.add_theme_color_override("font_color", Color.RED)
		warnin_label.text = "Hatalı giriş. Lütfen kart bilgilerini kontrol edin!"

# Klavyeden basılan tuşları dinleyen ana Godot fonksiyonu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Eğer basılan tuş ESC (Escape) ise:
		if event.keycode == KEY_ESCAPE:
			_on_button_geri_pressed()


func _on_gece_gunduz_pressed() -> void:
	is_night_mode =!is_night_mode
	var tween = create_tween()
	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33,0.4)
		
	else:
		tween.tween_property(night_overlay, "color:a", 0.0,0.4)


func _on_name_input_text_submitted(_new_text: String) -> void:
	$MainContent/RightPanel/CardNumInput.grab_focus()


func _on_exp_input_text_submitted(_new_text: String ) -> void:
	$MainContent/RightPanel/expAndCvcBox/CvcInput.grab_focus()
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			_on_pay_button_pressed()
	
func _on_card_num_input_text_submitted(_new_text: String) -> void:
	$MainContent/RightPanel/expAndCvcBox/ExpInput.grab_focus()
