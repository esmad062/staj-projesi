extends Node2D

# 1. Dışarıya haber ver
signal pressed

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_night: bool = false

func _on_gece_gunduz_bt_pressed() -> void:
	
	is_night = !is_night
	
	if is_night:
		animation_player.play("to_night")
	else:
		animation_player.play("to_day")
		
	# 2. Ana sahneye 
	pressed.emit()
