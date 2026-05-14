extends VBoxContainer

const PRIORITY_ALGOS = [
	"Priority (Non-Preemptive)",
	"Priority (Preemptive)",
	"Priority Round Robin"
]
const QUANTUM_ALGOS = [
	"Round Robin (RR)",
	"Priority Round Robin"
]

const ProcessRowScene = preload("res://scenes/process_row.tscn")

var show_priority_col := false
var show_quantum := false

@onready var algo_dropdown = $AlgorithmSection/AlgorithmDropdown
@onready var process_list  = $ProcessSection/ScrollContainer/ProcessList
@onready var add_row_btn   = $ProcessSection/AddRowBtn
@onready var run_button    = $ButtonsRow/RunButton
@onready var reset_button  = $ButtonsRow/ResetButton

signal simulation_requested(algo: String, processes: Array, quantum: int)
signal reset_requested

func _ready():
	print(algo_dropdown)
	print(process_list)
	print(add_row_btn)
	print(run_button)
	print(reset_button)
	var algos = [
		"First Come, First Serve (FCFS)",
		"Shortest Job First (SJF)",
		"Shortest Remaining Time (SRT)",
		"Round Robin (RR)",
		"Priority (Non-Preemptive)",
		"Priority (Preemptive)",
		"Priority Round Robin"
	]
	for a in algos:
		algo_dropdown.add_item(a)

	algo_dropdown.item_selected.connect(_on_algo_changed)
	add_row_btn.pressed.connect(_on_add_row)
	run_button.pressed.connect(_on_run_pressed)
	reset_button.pressed.connect(_on_reset_pressed)

	_on_add_row()
	_on_add_row()
	_on_add_row()

func _on_algo_changed(index: int):
	var algo_name = algo_dropdown.get_item_text(index)
	show_priority_col = algo_name in PRIORITY_ALGOS
	show_quantum      = algo_name in QUANTUM_ALGOS
	for row in process_list.get_children():
		row.show_priority(show_priority_col)

func _on_add_row():
	var row = ProcessRowScene.instantiate()
	process_list.add_child(row)
	row.show_priority(show_priority_col)
	row.row_deleted.connect(_renumber_rows)
	_renumber_rows()

func _renumber_rows():
	var rows = process_list.get_children()
	var at_minimum = rows.size() <= 3
	for i in rows.size():
		rows[i].set_id(i + 1)
		rows[i].delete_btn.disabled = at_minimum

func _on_run_pressed():
	var rows = process_list.get_children()
	if rows.size() < 3:
		return

	var data: Array = []
	for row in rows:
		var d = row.get_data()
		if d["burst"] <= 0:
			return
		data.append(d)

	var algo    = algo_dropdown.get_item_text(algo_dropdown.selected)
	var quantum = 2 if show_quantum else 1
	simulation_requested.emit(algo, data, quantum)

func _on_reset_pressed():
	for row in process_list.get_children():
		process_list.remove_child(row)
		row.free()
	show_priority_col = false
	show_quantum      = false
	algo_dropdown.select(0)
	_on_add_row()
	_on_add_row()
	_on_add_row()
	reset_requested.emit() 
