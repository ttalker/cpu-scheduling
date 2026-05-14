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

# load process rows
const ProcessRowScene = preload("res://scenes/process_row.tscn")

var show_priority_col := false
var show_quantum := false

@onready var algo_dropdown = %AlgorithmDropdown
@onready var quantum_section = %QuantumSection
@onready var quantum_input = %QuantumInput
@onready var priority_header = %PriorityHeader
@onready var process_list = %ProcessList
@onready var add_row_btn = %AddRowBtn
@onready var run_button = %RunButton
@onready var reset_button = %ResetButton

# signals for main simulatio scene

signal simulation_requested(algo: String, processes: Array, quantum: int)
signal reset_requested

func _ready():
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

	# do not show unless algo is that 
	quantum_section.visible = false
	priority_header.visible = false

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
	show_quantum = algo_name in QUANTUM_ALGOS

	quantum_section.visible = show_quantum
	priority_header.visible = show_priority_col

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

	var algo = algo_dropdown.get_item_text(algo_dropdown.selected)
	var quantum = int(quantum_input.value) if show_quantum else 1
	simulation_requested.emit(algo, data, quantum)

func _on_reset_pressed():
	for row in process_list.get_children():
		process_list.remove_child(row)
		row.free()

	show_priority_col = false
	show_quantum = false
	quantum_section.visible = false
	priority_header.visible = false
	algo_dropdown.select(0)

	_on_add_row()
	_on_add_row()
	_on_add_row()
	reset_requested.emit()
