extends Button

@onready var label: Label = $Label
@onready var spinner_label: Label = $spinner
@onready var check_label: Label = $onay

signal giris_animasyonu_bitti

func _ready() -> void:
	spinner_label.visible = false
	check_label.visible = false

func animasyon_baslat() -> void:
	emit_signal("giris_animasyonu_bitti")

func _on_pressed() -> void:
	disabled = true 
	
	# 1. Daralma ve Metin Gizleme
	var start_tween = create_tween().set_parallel(true)
	start_tween.tween_property(label, "modulate:a", 0.0, 0.2)
	start_tween.tween_property(self, "custom_minimum_size:x", 50.0, 0.3)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)
	
	await start_tween.finished
	
	spinner_label.visible = true
	
	spinner_label.pivot_offset = spinner_label.size / 2.0
	
	var spin_tween = create_tween().set_loops()
	spin_tween.tween_property(spinner_label, "rotation_degrees", 360.0, 0.6).from(0.0)
	
	# 2 Saniye simülasyon beklemesi
	await get_tree().create_timer(2.0).timeout
	
	# 3. Yüklemeyi Bitir ve Onay Emojisini Göster
	spin_tween.kill()
	spinner_label.visible = false
	
	check_label.visible = true
	check_label.pivot_offset = check_label.size / 2.0
	check_label.scale = Vector2.ZERO
	
	var check_tween = create_tween()
	check_tween.tween_property(check_label, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
