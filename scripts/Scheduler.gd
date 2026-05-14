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
	
	for p in process:
		if current_time < p.arrival_time:
			current_time = p.arrival_time  # if arrival time comes later it will assign current time as the arrival leaving a blank
		p.start_time  = current_time
		p.completion_time = current_time + p.burst_time
		current_time  = p.completion_time
		p.compute_stats()
		timeline.append({ "pid": p.pid, "start": p.start_time, "end": p.completion_time })

	return timeline

# SHORTEST JOB FIRST NON PREEMPTIVE

static func _run_sjf_np(processes: Array):
	var process = _clean_copy(processes)
	var timeline = []
	var current_time = 0
	var remaining = process.duplicate()
	
	while remaining.size() > 0:
		#get the ready queue
		var ready_queue = remaining.filter(func(x): return x.arrival_time <= current_time)
		
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

# SHORTEST REMAINING TIME ALGO

static func _run_srt(processes: Array) -> Array:
	var process = _clean_copy(processes)
	var timeline = []
	var current_time = 0
	var total_done = 0
	var n = process.size()
	
	while total_done < n:
		
		# get the ready queue
		var ready_queue = process.filter(func(x): 
			return x.arrival_time <= current_time and x.remaining_time > 0
		)
		
		if ready_queue.is_empty():
			
			var unfinished = process.filter(func(x): return x.remaining_time > 0)
			if unfinished.is_empty():
				break
			# Find the soonest arrival among unfinished processes
			var next = unfinished.reduce(func(a, b): 
				return a if a.arrival_time < b.arrival_time else b
			)
			current_time = next.arrival_time
			continue
		
		# Sort by remaining time, tie-break by arrival time
		ready_queue.sort_custom(func(a, b):
			if a.remaining_time == b.remaining_time:
				return a.arrival_time < b.arrival_time
			return a.remaining_time < b.remaining_time
		)
		
		var p = ready_queue[0]
		
		if p.start_time == -1:
			p.start_time = current_time
		
		# FIXED: find next arrival among processes NOT YET in the ready queue
		var not_yet_arrived = process.filter(func(x): 
			return x.arrival_time > current_time and x.remaining_time > 0
		)
		
		var next_arrival: int
		if not_yet_arrived.is_empty():
			next_arrival = current_time + p.remaining_time  # run to completion
		else:
			var nearest = not_yet_arrived.reduce(func(a, b): 
				return a if a.arrival_time < b.arrival_time else b
			)
			next_arrival = nearest.arrival_time
		
		# get how long the process runs
		var slice = min(p.remaining_time, next_arrival - current_time)
		
		if slice <= 0:
			slice = 1
		
		timeline.append({ "pid": p.pid, "start": current_time, "end": current_time + slice })
		
		p.remaining_time -= slice
		current_time += slice
		
		if p.remaining_time == 0:
			p.completion_time = current_time
			p.compute_stats()
			total_done += 1
	
	return _merge_blocks(timeline) 
	

# DUPLICATE SHI IS MERGED

static func _merge_blocks(timeline: Array) -> Array:
	if timeline.is_empty():
		return []
	var merged = [timeline[0].duplicate()]
	for i in range(1, timeline.size()):
		var last = merged[-1]
		var cur  = timeline[i]
		if cur["pid"] == last["pid"] and cur["start"] == last["end"]:
			last["end"] = cur["end"]
		else:
			merged.append(cur.duplicate())
	return merged

# ROUND ROBIN ALGO

static func _run_rr(processes: Array, quantum: int) -> Array:
	var process = _clean_copy(processes)
	process.sort_custom(func(a, b): return a.arrival_time < b.arrival_time)
	
	var timeline = []
	var queue = []
	var current_time = 0
	var proc_index = 0
	
	queue.append(process[proc_index])
	proc_index += 1
	
	while not queue.is_empty():
		var p = queue.pop_front()
		
		if p.start_time == -1:
			p.start_time = current_time
			
		var slice = min(p.remaining_time, quantum)
		timeline.append({ "pid": p.pid, "start": current_time, "end": current_time + slice })
		
		current_time += slice
		p.remaining_time -= slice
		
		while proc_index < process.size() and process[proc_index].arrival_time <= current_time:
			queue.append(process[proc_index])
			proc_index += 1
			
		if p.remaining_time > 0:
			queue.append(p)
		else:
			p.completion_time = current_time
			p.compute_stats()
			
	return timeline	

static func _run_priority_np(processes: Array) -> Array:
	var process = _clean_copy(processes)
	var remaining = process.duplicate()
	var timeline = []
	var current_time = 0
	
	while remaining.size() > 0:
		var available = remaining.filter(func(p): return p.arrival_time <= current_time)
		
		if available.is_empty():
			var next     = remaining.reduce(func(a, b): return a if a.arrival_time < b.arrival_time else b)
			current_time = next.arrival_time
			continue
			
		available.sort_custom(func(a, b):
			if a.priority == b.priority:
				return a.arrival_time < b.arrival_time
			return a.priority < b.priority
		)
		
		var p = available[0]
		p.start_time = current_time
		p.completion_time = current_time + p.burst_time
		current_time = p.completion_time
		p.compute_stats()
		
		timeline.append({ "pid": p.pid, "start": p.start_time, "end": p.completion_time })
		remaining.erase(p)
		
	return timeline
	
static func _run_priority_p(processes: Array) -> Array:
	var process = _clean_copy(processes)
	var timeline = []
	var current_time = 0
	var total_done = 0
	var n = process.size()
	while total_done < n:
		
		var ready_queue = process.filter(func(x):
			return x.arrival_time <= current_time and x.remaining_time > 0
		)
		
		if ready_queue.is_empty():
			var unfinished = process.filter(func(x): return x.remaining_time > 0)
			if unfinished.is_empty():
				break
				
			var next = unfinished.reduce(func(a, b): return a if a.arrival_time < b.arrival_time else b)
			current_time = next.arrival_time
			continue
			
		ready_queue.sort_custom(func(a, b):
			if a.priority == b.priority:
				return a.arrival_time < b.arrival_time
			return a.priority < b.priority
		)
		
		var p = ready_queue[0]
		
		if p.start_time == -1:
			p.start_time = current_time
			
		var not_yet_arrived = process.filter(func(x):
			return x.arrival_time > current_time and x.remaining_time > 0
		)
		
		var next_arrival: int
		if not_yet_arrived.is_empty():
			next_arrival = current_time + p.remaining_time
		else:
			var nearest = not_yet_arrived.reduce(func(a, b): return a if a.arrival_time < b.arrival_time else b)
			next_arrival = nearest.arrival_time
			
		var slice = min(p.remaining_time, next_arrival - current_time)
		if slice <= 0:
			slice = 1
			
		timeline.append({ "pid": p.pid, "start": current_time, "end": current_time + slice })
		
		p.remaining_time -= slice
		current_time += slice
		
		if p.remaining_time == 0:
			p.completion_time = current_time
			p.compute_stats()
			total_done += 1
			
	return _merge_blocks(timeline)

# PRIORITY WITH RR ALGO 

static func _run_priority_rr(processes: Array, quantum: int) -> Array:
	var process = _clean_copy(processes)
	
	process.sort_custom(func(a, b):
		if a.priority == b.priority:
			return a.arrival_time < b.arrival_time
		return a.priority < b.priority
	)
	
	var timeline : Array = []
	var queues : Dictionary = {}
	var current_time : int = 0
	var total_done : int = 0
	var n : int = process.size()
	var proc_index : int = 0

	# enqueue all processes available at t=0
	while proc_index < n and process[proc_index].arrival_time <= current_time:
		var p = process[proc_index]
		if not queues.has(p.priority):
			queues[p.priority] = []
		queues[p.priority].append(p)
		proc_index += 1

	while total_done < n:

		# pull in anything that has arrived by now
		while proc_index < n and process[proc_index].arrival_time <= current_time:
			var p = process[proc_index]
			if not queues.has(p.priority):
				queues[p.priority] = []
			queues[p.priority].append(p)
			proc_index += 1

		# pick highest priority (lowest number) queue with work
		var active_level = _get_highest_priority_level(queues)

		# idle — nothing ready yet, jump to next arrival
		if active_level == -1:
			if proc_index < n:
				current_time = process[proc_index].arrival_time
			continue

		# pop from the front of that priority queue
		var p = queues[active_level].pop_front()

		if p.start_time == -1:
			p.start_time = current_time

		var slice_start : int  = current_time
		var time_ran : int  = 0
		var preempted : bool = false

		# run tick by tick up to quantum
		while time_ran < quantum and p.remaining_time > 0:
			current_time += 1
			time_ran += 1
			p.remaining_time -= 1
			
			# enqueue arrivals during this tick
			while proc_index < n and process[proc_index].arrival_time <= current_time:
				var np = process[proc_index]
				if not queues.has(np.priority):
					queues[np.priority] = []
				queues[np.priority].append(np)
				proc_index += 1
				
			# preempt only if strictly higher priority arrived
			var best_now = _get_highest_priority_level(queues)
			if best_now != -1 and best_now < active_level:
				preempted = true
				break
				
		
		timeline.append({ "pid": p.pid, "start": slice_start, "end": current_time })
		
		if p.remaining_time == 0:
			p.completion_time = current_time
			p.compute_stats()
			total_done += 1
		else:
			if not queues.has(active_level):
				queues[active_level] = []
			queues[active_level].append(p)
			
	return timeline  

static func _get_highest_priority_level(queues: Dictionary) -> int:
	var best = -1
	for level in queues.keys():
		if not queues[level].is_empty():
			if best == -1 or level < best:
				best = level
	return best

static func _compute_averages(processes: Array) -> Dictionary:
	var total_wt = 0
	var total_tat = 0
	var total_rt = 0
	for p in processes:
		total_wt += p.waiting_time
		total_tat += p.turnaround_time
	var n = processes.size()
	return {
		"avg_wt":  float(total_wt)  / n,
		"avg_tat": float(total_tat) / n,
		"avg_rt":  float(total_rt)  / n
	}
