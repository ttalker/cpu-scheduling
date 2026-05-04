class_name Scheduler

# used a class so you just call Scheduler.method name 

static func _clean_copy(processes: Array) -> Array:
	var clean_copy = [] # where the new copy will be stored
	for p in processes:
		var new_process = Process.new(p.pid, p.arrival_time, p.burst_time, p.priority)
		clean_copy.append(new_process)
	return clean_copy

# FIRST COME FIRST SERVE ALGO

static func _run_fcfs(processes: Array):
	var process = _clean_copy(processes) # clean copy of array
	
	# sort by arrival time
	process.sort_custom(func(a, b): return a.arrival_time < b.arrival_time)
	
	var timeline = [] # array of dictionary
	var current_time = 0
	
	for p in processes:
		if current_time > p.arrival_time:
			current_time = p.arrival_time  # if arrival time comes later it will assign current time as the arrival leaving a blank
		p.start_time  = current_time
		p.completion_time = current_time + p.burst_time
		current_time  = p.completion_time
		p.compute_stats()
		timeline.append({ "pid": p.pid, "start": p.start_time, "end": p.completion_time })

	return timeline



	
	
