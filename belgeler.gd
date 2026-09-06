extends Control

@onready var document_list = $MainContent/RightPanel/DocumentList
@onready var doc_type_option = $MainContent/LeftPanel/DocumentOption1
@onready var lang_option = $MainContent/LeftPanel/LanguageOp

const SIDEBAR_SCENE = preload("res://GERCEK/side_bar.tscn") 

var sidebar_instance: Node = null

var night_overlay: ColorRect
var is_night_mode = false

func _ready() -> void:
	gece_modu_hazirla()
	
	if has_node("Button2"):
		$Button2.pressed.connect(_on_cıkıs_pressed)
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var sidebar = SIDEBAR_SCENE.instantiate()
	canvas_layer.add_child(sidebar)
	
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)

	_option_buttonlari_doldur()
	listeyi_yenile()
	
func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	night_overlay.color = Color(0,0,0,0)
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE	
	add_child(night_overlay)
	
func _option_buttonlari_doldur():
	if doc_type_option.get_item_count() == 0:
		doc_type_option.add_item("Belge Türü Seçiniz...")
		doc_type_option.add_item("Öğrenci Belgesi")
		doc_type_option.add_item("Transkript (Not Döküm)")
		doc_type_option.add_item("Disiplin Durum Belgesi")
	if lang_option.get_item_count() == 0:
		lang_option.add_item("Belge Dili Seçiniz...")
		lang_option.add_item("Türkçe")
		lang_option.add_item("İngilizce")

func listeyi_yenile():
	document_list.clear()
	for i in range(GlobalData.gecmis_talepler.size()-1, -1, -1)	:
		var item = GlobalData.gecmis_talepler[i]
		var satir = item["tarih"] + " - " + item["belge"] + " [" + item["durum"] + "]"
		document_list.add_item(satir)
		
#func gecmis_talepleri_yukle():
	document_list.clear() # önce temizlesin
	
	for talep in GlobalData.gecmis_talepler:
		var satir_metni = talep["tarih"] + " - " + talep["belge"] + "(" + talep["durum"] + ")"
		document_list.add_item(satir_metni)
		
func _on_cıkıs_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/ogrenci_islemleri.tscn")


func _on_talebi_al_pressed() -> void:
	if doc_type_option.selected <= 0 or lang_option.selected <= 0:
		print("Lütfen belge türü ve dilini seçiniz!
		return")
	
	var belge_adi = doc_type_option.get_item_text(doc_type_option.selected)
	var dil_adi = lang_option.get_item_text(lang_option.selected)
	
	GlobalData.talep_ekle(belge_adi, dil_adi)
	listeyi_yenile()
	#seçimleri sıfırla
	doc_type_option.selected = 0
	lang_option.selected = 0
	
	# Klavyeden basılan tuşları dinleyen ana Godot fonksiyonu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Eğer basılan tuş ESC (Escape) ise:
		if event.keycode == KEY_ESCAPE:
				_on_cıkıs_pressed()


func _on_gece_gunduz_pressed() -> void:
	is_night_mode = !is_night_mode
	var tween = create_tween()
	if is_night_mode:
		tween.tween_property(night_overlay, "color:a", 0.33, 0.4)
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)
