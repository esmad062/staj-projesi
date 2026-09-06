extends Control

@onready var tcno = $VBoxContainer/TC/TC2
@onready var ogrenciNo = $VBoxContainer/Ogrenci/Ogrenci2
@onready var bolum = $VBoxContainer/Bolum/Bolum2
@onready var program = $VBoxContainer/Programi/Program2
@onready var mezun = $VBoxContainer/Mezuniyet/Mezun
@onready var durum = $VBoxContainer/Durum/Durum2
@onready var ogrenciresmi = $TextureRect3
@onready var dosya_diyalog = $FileDialog

@onready var SIDEBAR_SCENE = preload("res://GERCEK/side_bar.tscn")
var night_overlay: ColorRect
var is_night_mode = false

func _ready() -> void:
	print("--- BİLGİLERİM EKRANI YÜKLENİYOR ---")
	
	if has_node("Button"):
		$Button.pressed.connect(_on_geri_don_pressed)
	
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)
	if dosya_diyalog and not dosya_diyalog.file_selected.is_connected(_on_dosya_secildi):
		dosya_diyalog.file_selected.connect(_on_dosya_secildi)
		
	gece_modu_hazirla()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var sidebar = SIDEBAR_SCENE.instantiate()
	canvas_layer.add_child(sidebar)
	
	# GlobalData'dan aktif öğrencinin verilerini çekiyoruz
	print("Aktif Öğrenci Numarası: ", GlobalData.aktif_ogrenci_no)
	var kisi = GlobalData.kullanici_bul_by_id(GlobalData.aktif_ogrenci_no)
	
	if kisi == null or kisi.size() == 0:
		print("UYARI: ID ile bulunamadı, mevcut_kullanici deneniyor...")
		kisi = GlobalData.mevcut_kullanici

	print("Yüklenen Kişi Verisi: ", kisi)

	if kisi != null and kisi.size() > 0:
		tcno.text = str(kisi.get("tc_no", ""))
		ogrenciNo.text = str(kisi.get("ogrenci_no", ""))
		bolum.text = str(kisi.get("bolumu", ""))
		program.text = str(kisi.get("programi", ""))
		durum.text = str(kisi.get("durumu", ""))
		mezun.text = str(kisi.get("mezuniyet", ""))
	
		var resim_yolu = str(kisi.get("resim", ""))
		print("Aranan Resim Yolu: ", resim_yolu)
		
		if resim_yolu != "" and ResourceLoader.exists(resim_yolu):
			ogrenciresmi.texture = load(resim_yolu)
			print("PROFİL RESMİ BAŞARIYLA YÜKLENDİ!")
		else:
			print("HATA: Resim dosyası bulunamadı veya yol hatalı! Yol: ", resim_yolu)
	else:
		print("HATA: Kullanıcı verisi tamamen boş!")

func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	night_overlay.color = Color(0, 0, 0, 0)
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(night_overlay)

func _on_geri_don_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/dashboard.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_geri_don_pressed()

func _on_gece_gunduz_pressed() -> void:
	is_night_mode = !is_night_mode
	var tween = create_tween()
	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33, 0.4)
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)

func _on_fotograf_degistir_pressed() -> void:
	dosya_diyalog.popup_centered(Vector2i(700, 500))

func _on_dosya_secildi(path: String) -> void:
	print("--- SEÇİLEN DOSYA: ", path)
	if path.ends_with(".import"):
		path = path.trim_suffix(".import")
		
	var img = Image.load_from_file(path)
	if img:
		ogrenciresmi.texture = ImageTexture.create_from_image(img)

func _resim_yukle(resim_yolu: String) -> void:
	if resim_yolu == "":
		resim_yolu = "res://images/resim1.png"
	
	# Eğer yol res:// ile başlamıyorsa düzelt
	if not resim_yolu.begins_with("res://"):
		resim_yolu = "res://" + resim_yolu
	
	# Önce direk dene
	if ResourceLoader.exists(resim_yolu):
		var texture = load(resim_yolu)
		if texture:
			$profil_resmi.texture = texture
			print("✅ Profil resmi başarıyla yüklendi: ", resim_yolu)
			return
	
	# Alternatif yolları dene
	var dosya_adi = resim_yolu.get_file()
	var alternatif_yollar = [
		"res://images/" + dosya_adi,
		"res://" + dosya_adi
	]
	
	for yol in alternatif_yollar:
		if ResourceLoader.exists(yol):
			var texture = load(yol)
			if texture:
				$profil_resmi.texture = texture
				print("✅ Profil resmi alternatif yoldan yüklendi: ", yol)
				return
	
	# Varsayılan resim
	var varsayilan = load("res://images/resim1.png")
	if varsayilan:
		$profil_resmi.texture = varsayilan
		print("⚠️ Varsayılan resim kullanılıyor")
