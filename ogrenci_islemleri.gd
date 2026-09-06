extends Control

@onready var SIDEBAR_SCENE = preload("res://GERCEK/side_bar.tscn")
var night_overlay : ColorRect
var is_nigth_mode=false

func _ready() -> void:
	gece_modu_hazirla()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var sidebar = SIDEBAR_SCENE.instantiate()
	canvas_layer.add_child(sidebar)
	
	if has_node("Gece_gunduz"):
		$Gece_gunduz.pressed.connect(_on_gece_gunduz_pressed)
		
	if has_node("Button"):
		$Button.pressed.connect(_on_geri_don_pressed)

func gece_modu_hazirla() -> void:
	night_overlay = ColorRect.new()
	night_overlay.name = "NightOverlay"
	night_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	night_overlay.color = Color(0,0,0,0)
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(night_overlay)

func _on_geri_don_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/dashboard.tscn")
	
func _on_odeme_b_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/odeme_ekrani.tscn")

func _on_belge_pressed() -> void:
	get_tree().change_scene_to_file("res://GERCEK/belgeler.tscn")

# Klavyeden basılan tuşları dinleyen ana Godot fonksiyonu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Eğer basılan tuş ESC (Escape) ise:
		if event.keycode == KEY_ESCAPE:
			_on_geri_don_pressed()


func _on_gece_gunduz_pressed() -> void:
	is_nigth_mode = !is_nigth_mode
	var tween = create_tween()
	if is_nigth_mode:
		tween.tween_property(night_overlay, "color:a", 0.33, 0.4)
	else:
		tween.tween_property(night_overlay, "color:a", 0.0, 0.4)
