extends Control

@onready var panel_kutusu = $Panel # Sahnendeki Panel node'u

func _ready() -> void:
	duyurulari_listele()

func duyurulari_listele() -> void:
	
	if not "duyurular" in GlobalData or GlobalData.duyurular.size() == 0:
		return
		
	
	for child in panel_kutusu.get_children():
		child.queue_free()
		
	
	var dikey_liste = VBoxContainer.new()
	dikey_liste.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_kutusu.add_child(dikey_liste)
		
	for duyuru in GlobalData.duyurular:
		var kart_panel = PanelContainer.new()
		var margin = MarginContainer.new()
		var vbox_icerik = VBoxContainer.new()
		
		# Başlık ve Tarih
		var baslik_label = Label.new()
		baslik_label.text = "📢 " + str(duyuru.get("baslik", "")) + " (" + str(duyuru.get("tarih", "")) + ")"
		baslik_label.add_theme_font_size_override("font_size", 14)
		baslik_label.add_theme_color_override("font_color", Color(0, 0, 0)) # Siyah yazı
		
		# İçerik
		var icerik_label = Label.new()
		icerik_label.text = str(duyuru.get("icerik", ""))
		icerik_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		icerik_label.add_theme_font_size_override("font_size", 11)
		icerik_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2)) # Koyu gri yazı
		
		# Hiyerarşik Ekleme
		vbox_icerik.add_child(baslik_label)
		vbox_icerik.add_child(icerik_label)
		margin.add_child(vbox_icerik)
		kart_panel.add_child(margin)
		
		
		dikey_liste.add_child(kart_panel)

# Geri Butonu Bağlantısı (Eğer buton eklediysen)
func _on_geri_button_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/dashboard.tscn")
