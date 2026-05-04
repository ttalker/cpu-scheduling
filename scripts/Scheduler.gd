class_name Scheduler

# used a class so you just call Scheduler.method name 

static func _clean_copy(processes: Array) -> Array:
	var clean_copy = [] # where the new copy will be stored
	for p in processes:
		var new_process = Process.new(p.pid, p.arrival_time, p.burst_time, p.priority)
		clean_copy.append(new_process)
	return clean_copy
