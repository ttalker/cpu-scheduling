class_name Process

var pid: String # p1, p2  
var arrival_time: int
var burst_time: int
var priority: int
var response_time: int

# to be computed by the scheduler
var completion_time: int
var remaining_time: int  
var start_time: int      
var turnaround_time: int
var waiting_time: int

func _init(p: String, at: int, bt: int, pri: int = 0) -> void:
	pid = p
	arrival_time = at
	burst_time = bt
	priority = pri # default is 0
	remaining_time = bt  
	completion_time = -1 # -1 represents not completed or not started
	start_time = -1
	response_time = -1

func compute_stats() -> void:
	turnaround_time = completion_time - arrival_time
	waiting_time    = turnaround_time - burst_time
	response_time   = start_time - arrival_time

func reset() -> void:
	remaining_time = burst_time   
	completion_time = -1           
	start_time = -1
	response_time = -1
		
