extends CanvasLayer

@onready var vbox = $ScrollContainer/VBoxContainer
@onready var ac_kapa_butonu = $Button
@onready var arka_plan = $TextureRect
@onready var scroll_container = $ScrollContainer

var acik_mi: bool = false

# Butonun kapalı ve açık hallerdeki boyut tanımları
var kapali_boyut: Vector2 = Vector2(50, 50)   # Küçük kare/yuvarlak hal 
var acik_boyut: Vector2 = Vector2(300, 40)    # Panelin dikey alt tabanına tam oturacak yatay genişlik

func _ready() -> void:
	# Başlangıçta paneller gizli ve buton kapalı boyutta
	paneli_guncelle(false)
	ac_kapa_butonu.custom_minimum_size = kapali_boyut
	
	# ScrollContainer yatay kaymayı engellesin
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	# Buton bağlantısı
	if not ac_kapa_butonu.pressed.is_connected(_on_ac_kapa_pressed):
		ac_kapa_butonu.pressed.connect(_on_ac_kapa_pressed)

func _on_ac_kapa_pressed() -> void:
	acik_mi = !acik_mi
	
	# Hedef boyutu belirliyoruz
	var hedef_boyut = acik_boyut  if acik_mi else kapali_boyut
	
	# Tween ile custom_minimum_size 
	var tween = create_tween().set_parallel(true)
	tween.tween_property(ac_kapa_butonu, "custom_minimum_size", hedef_boyut, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	paneli_guncelle(acik_mi)

func paneli_guncelle(durum: bool) -> void:
	arka_plan.visible = durum
	scroll_container.visible = durum

func bildirimleri_yukle(bildirim_listesi: Array) -> void:
	# Eski elemanları temizle
	for child in vbox.get_children():
		child.queue_free()
		
	for i in range(bildirim_listesi.size()):
		var item = bildirim_listesi[i]
		
		# Başlık Label
		var lbl_baslik = Label.new()
		lbl_baslik.text = "BAŞLIK: " + item.get("baslik", "")
		lbl_baslik.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_baslik.custom_minimum_size = Vector2(250, 0)
		lbl_baslik.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_baslik.add_theme_font_size_override("font_size", 16)
		lbl_baslik.add_theme_color_override("font_color", Color(0,0,0))
		vbox.add_child(lbl_baslik)

		# İçerik Label
		var lbl_icerik = Label.new()
		lbl_icerik.text = "İÇERİK:\n" + item.get("icerik", "")
		lbl_icerik.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_icerik.custom_minimum_size = Vector2(250, 0)
		lbl_icerik.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_icerik.add_theme_font_size_override("font_size", 14)
		lbl_icerik.add_theme_color_override("font_color", Color.DIM_GRAY)
		vbox.add_child(lbl_icerik)
		
		# Son eleman değilse araya çizgi (HSeparator) koy
		if i < bildirim_listesi.size() - 1:
			var cizgi = HSeparator.new()
			vbox.add_child(cizgi)
