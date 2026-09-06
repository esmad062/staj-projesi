extends Control

@onready var name_label = $OnYuz/Name
@onready var number_label = $ArkaYuz/Kart
@onready var date_label = $OnYuz/Month
@onready var cvv_label = $ArkaYuz/CVV

func update_name(new_text: String) -> void:
	name_label.text = new_text

func update_number(new_text: String) -> void:
	number_label.text = new_text

func update_date(new_text: String) -> void:
	date_label.text = new_text
	
func update_cvv(new_text: String) -> void:
	cvv_label.text = new_text
