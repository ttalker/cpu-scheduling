extends VBoxContainer

@onready var table_container = $TableContainer

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

# fill in the table

func populate(processes: Array):
	var children = table_container.get_children()
	for i in range(1, children.size()):
		children[i].queue_free()

	for p in processes:
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var cells = [
			p.pid,
			str(p.arrival_time),
			str(p.burst_time),
			str(p.start_time),
			str(p.completion_time),
			str(p.waiting_time),
			str(p.turnaround_time)
		]

		for value in cells:
			var lbl = Label.new()
			lbl.text = value
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
			row.add_child(lbl)

		table_container.add_child(row)

func reset():
	var children = table_container.get_children()
	for i in range(1, children.size()):
		children[i].queue_free()
