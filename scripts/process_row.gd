extends Control

signal row_deleted

@onready var id_label = $Inputs/IDLabel
@onready var arrival_input = $Inputs/ArrivalInput
@onready var burst_input = $Inputs/BurstInput
@onready var priority_input = $Inputs/PriorityInput
@onready var delete_btn = $Inputs/DeleteBtn

func _ready():
	delete_btn.pressed.connect(_on_delete_pressed)

func set_id(n: int):
	id_label.text = "P" + str(n)

func show_priority(value: bool):
	priority_input.visible = value

func get_data() -> Dictionary:
	return {
		"id":       id_label.text,
		"arrival":  arrival_input.text.to_int(),
		"burst":    burst_input.text.to_int(),
		"priority": priority_input.text.to_int() if priority_input.visible else 0
	}

func _on_delete_pressed():
	row_deleted.emit()
	queue_free()
