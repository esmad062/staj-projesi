extends Control
'''    DEĞİŞKENLER    '''

@onready var ismi = $VBoxContainer/Ismi
@onready var bolum = $VBoxContainer/Bolum
@onready var ofisi = $VBoxContainer/Ofisi
@onready var ofisTel = $VBoxContainer/OfisTel
@onready var maili = $VBoxContainer/Eposta
# Sidebar sahnesi
@onready var SIDEBAR_SCENE = preload("res://GERCEK/side_bar.tscn")
@onready var resim = $Resmi
# ekran karartması için değişkenler
var night_overlay : ColorRect
var is_night_mode = false

#popup için değişkenler
var mail_onayi: AcceptDialog
var popup_icerik_lable: Label
var popup_baslik_label: Label

''' READY FONKSİYONU '''
func _ready() -> void:
	popup_penceresi_olustur()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var sidebar = SIDEBAR_SCENE.instantiate()
	canvas_layer.add_child(sidebar)
	
	danisman_ekranini_doldur()
	gece_modu_hazirla()
	
	if has_node("Button"):
		$Button.pressed.connect(_on_geri_don_pressed)
	
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)
	
	var danisman_bilgisi = GlobalData.aktif_danisman_bilgisi_getir()
	
	# Eğer danışman bulunduysa
	if danisman_bilgisi != null and danisman_bilgisi.size() > 0:
		ismi.text = danisman_bilgisi.get("Danisman isim", "Bilgi yok")
		bolum.text = danisman_bilgisi.get("bolumu", "Bilgi yok")
		ofisi.text = danisman_bilgisi.get("ofisi", "Bilgi yok")
		ofisTel.text = danisman_bilgisi.get("ofisTel", "Bilgi yok")
		maili.text = danisman_bilgisi.get("mail", "Bilgi yok")
		
		# Resim varsa yükle
		if danisman_bilgisi.has("resim"):
			var resim_yolu = danisman_bilgisi.get("resmi", "")
			if resim_yolu != "" and resim:
				resim.texture = load(resim_yolu)
		
		print("Danışman bilgileri yüklendi: ", danisman_bilgisi.get("Danisman isim", ""))
	else:
		print("Danışman bulunamadı! Öğrenci no: ", GlobalData.aktif_ogrenci_no)
		ismi.text = "Danışman atanmamış"
		bolum.text = "-"
		ofisi.text = "-"
		ofisTel.text = "-"
		maili.text = "-"

func danisman_ekranini_doldur() -> void:
	# Doğrudan GlobalData'daki doğru danışmanı çekiyoruz
	var d = GlobalData.aktif_danisman_bilgisi_getir()
	if d.is_empty():
		return
		
	
	var danisman_resim_yolu = str(d.get("resmi", ""))
	
	if has_node("Resmi") and danisman_resim_yolu != "":
		if ResourceLoader.exists(danisman_resim_yolu):
			$Resmi.texture = load(danisman_resim_yolu)
			print("Danışman resmi başarıyla yüklendi: ", danisman_resim_yolu)
		else:
			print("Resim dosyası klasörde/dizinde bulunamadı: ", danisman_resim_yolu)


func popup_penceresi_olustur() -> void:
	
	mail_onayi = ConfirmationDialog.new()
	mail_onayi.title = " "
	mail_onayi.ok_button_text = "EVET"
	mail_onayi.cancel_button_text = "VAZGEÇ" # İptal butonu metni
	mail_onayi.size = Vector2(200, 160)
	mail_onayi.exclusive = true
	
	var gri_bg = StyleBoxFlat.new()
	gri_bg.bg_color = Color(0.92, 0.93, 0.95)
	gri_bg.set_corner_radius_all(10)
	gri_bg.content_margin_bottom = 16
	gri_bg.content_margin_left = 16
	gri_bg.content_margin_right = 16
	gri_bg.content_margin_top = 16
	
	mail_onayi.add_theme_stylebox_override("panel", gri_bg)
	
	var vbox_ana = VBoxContainer.new()
	vbox_ana.add_theme_constant_override("separation", 10)
	
	popup_baslik_label = Label.new()
	popup_baslik_label.add_theme_font_size_override("font_size", 16)
	popup_baslik_label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.15))
	popup_baslik_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_ana.add_child(popup_baslik_label)
	
	vbox_ana.add_child(HSeparator.new())
	
	popup_icerik_lable = Label.new()
	popup_icerik_lable.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	popup_icerik_lable.add_theme_font_size_override("font_size", 13)
	popup_icerik_lable.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	popup_icerik_lable.custom_minimum_size = Vector2(320, 100)
	vbox_ana.add_child(popup_icerik_lable)
	
	
	mail_onayi.add_child(vbox_ana)
	add_child(mail_onayi)

func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	night_overlay.color = Color(0,0,0,0)
	
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(night_overlay)


# Mail Gönder Butonuna Basıldığında:
func _on_mail_gonder_pressed() -> void:
	var danisman_veri = GlobalData.aktif_danisman_bilgisi_getir()
	var eposta = danisman_veri.get("mail", "")
	var danisman_adi = danisman_veri.get("Danisman isim", "Danışmanınız")
	
	if eposta == "":
		print("Mail adresi bulunamadı!")
		return

	popup_baslik_label.text = "E-posta Gönder"
	popup_icerik_lable.text = danisman_adi + " kişisine e-posta göndermek istiyor musunuz?"
	
	# Eski sinyalleri temizle
	if mail_onayi.confirmed.is_connected(_randevu_onayla):
		mail_onayi.confirmed.disconnect(_randevu_onayla)
	if mail_onayi.confirmed.is_connected(_mail_yonlendir_caller):
		mail_onayi.confirmed.disconnect(_mail_yonlendir_caller)
		
	# Onaylanınca mail uygulamasını aç
	mail_onayi.confirmed.connect(func(): _mail_yonlendir(eposta))
	mail_onayi.popup_centered()

func _mail_yonlendir_caller():
	pass 

func _mail_yonlendir(target_mail: String) -> void:
	if target_mail != "":
		var mail_uri = "mailto:" + target_mail + "?subject=" + "Danışman Bilgilendirme Talebi".uri_encode()
		OS.shell_open(mail_uri)
func _on_randevu_al_pressed() -> void:
	print("Randevu pop-up'ı açıldı.")
	popup_baslik_label.text = "Randevu Talebi"
	popup_icerik_lable.text = "Danışmanınızdan randevu talep etmek istediğinize emin misiniz?"
	
	
	if mail_onayi.confirmed.is_connected(_mail_yonlendir):
		mail_onayi.confirmed.disconnect(_mail_yonlendir)
	if mail_onayi.confirmed.is_connected(_randevu_onayla):
		mail_onayi.confirmed.disconnect(_randevu_onayla)
		
	mail_onayi.confirmed.connect(_randevu_onayla)
	mail_onayi.popup_centered()
	
func _randevu_onayla() -> void:
	print("Randevu talebi danışmana iletildi.")
	
func _on_gece_gunduz_pressed() -> void:
	is_night_mode = !is_night_mode
	var tween = create_tween()

	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33, 0.4)
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)	
	
func _on_geri_don_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/dashboard.tscn")
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_geri_don_pressed()
	
			

func _danisman_resmi_yukle(resim_yolu: String) -> void:
	if resim_yolu == "" or not ResourceLoader.exists(resim_yolu):
		# Alternatif yolları dene
		var dosya_adi = resim_yolu.get_file() if resim_yolu != "" else "resim1.png"
		var alternatif_yollar = [
			"res://images/" + dosya_adi,
			"res://" + dosya_adi,
			"res://images/resim1.png"
		]
		
		for yol in alternatif_yollar:
			if ResourceLoader.exists(yol):
				$danisman_resmi.texture = load(yol)
				print("✅ Danışman resmi yüklendi: ", yol)
				return
	else:
		$danisman_resmi.texture = load(resim_yolu)
		print("✅ Danışman resmi yüklendi: ", resim_yolu)
			
			
