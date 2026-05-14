# simulation_scene.gd
extends Control

@onready var input_panel   = $"Main Layout/InputPanel"
@onready var results_panel = $"Main Layout/VBoxContainer/ResultsPanel"
@onready var gantt_chart   = $"Main Layout/VBoxContainer/GanttChart"
@onready var process_table = $"Main Layout/VBoxContainer/ProcessTable"

func _ready():
	input_panel.simulation_requested.connect(_on_simulation_requested)
	input_panel.reset_requested.connect(_on_reset)
	
func _on_reset():
	results_panel.reset()
	gantt_chart.reset()
	process_table.reset()

func _on_simulation_requested(algo: String, raw_data: Array, quantum: int):
	# Build process objects
	var processes: Array = []
	for d in raw_data:
		var p = Process.new(d["id"], d["arrival"], d["burst"], d["priority"])
		processes.append(p)

	# Run scheduler — it works on a clean copy internally
	var timeline: Array = []
	match algo:
		"First Come, First Serve (FCFS)":
			timeline = Scheduler._run_fcfs(processes)
		"Shortest Job First (SJF)":
			timeline = Scheduler._run_sjf_np(processes)
		"Shortest Remaining Time (SRT)":
			timeline = Scheduler._run_srt(processes)
		"Round Robin (RR)":
			timeline = Scheduler._run_rr(processes, quantum)
		"Priority (Non-Preemptive)":
			timeline = Scheduler._run_priority_np(processes)
		"Priority (Preemptive)":
			timeline = Scheduler._run_priority_p(processes)
		"Priority Round Robin":
			timeline = Scheduler._run_priority_rr(processes, quantum)

	if timeline.is_empty():
		return

	# Rebuild stats on our local processes from the timeline
	# since scheduler works on its own clean copy
	_apply_stats(processes, timeline)

	var total_time = timeline[timeline.size() - 1]["end"]
	var busy_time  = 0
	for block in timeline:
		busy_time += block["end"] - block["start"]
	var cpu_util = (float(busy_time) / total_time * 100.0) if total_time > 0 else 0.0

	var averages = Scheduler._compute_averages(processes)

	results_panel.populate(averages, total_time, cpu_util)
	gantt_chart.display(timeline, processes)
	process_table.populate(processes)

func _apply_stats(processes: Array, timeline: Array) -> void:
	# Build a lookup of first start and last end per pid from timeline
	var first_start : Dictionary = {}
	var last_end    : Dictionary = {}

	for block in timeline:
		var pid = block["pid"]
		if not first_start.has(pid):
			first_start[pid] = block["start"]
		last_end[pid] = block["end"]

	for p in processes:
		if first_start.has(p.pid):
			p.start_time      = first_start[p.pid]
			p.completion_time = last_end[p.pid]
			p.compute_stats()
