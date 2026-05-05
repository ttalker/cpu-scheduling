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

# SHORTEST JOB FIRSST NON PREEMPTIVE

static func _run_sjf_np(processes: Array):
	var process = _clean_copy(processes)
	var timeline = []
	var current_time = 0
	var remaining = process.duplicate()
	
	while remaining.size() > 0:
		#get the ready queue
		var ready_queue = remaining.filter(func(p): return p.arrival_time <= current_time)
		
		if ready_queue.is_empty():
			# Jump to next arrival (idle)
			var next = remaining.reduce(func(a, b): return a if a.arrival_time < b.arrival_time else b)
			current_time = next.arrival_time
			continue
			
		# sort by burst time, tie break by arrival time
		ready_queue.sort_custom(func(a, b):
			if a.burst_time == b.burst_time:
				return a.arrival_time < b.arrival_time
			return a.burst_time < b.burst_time)
		
		var p = ready_queue[0]
		
		p.start_time  = current_time
		p.completion_time = current_time + p.burst_time
		current_time  = p.completion_time
		p.compute_stats()
		timeline.append({ "pid": p.pid, "start": p.start_time, "end": p.completion_time })
		
		# since this is non-preemptive, after
		remaining.erase(p)
	
	return timeline
	
	
	
	
	
	
