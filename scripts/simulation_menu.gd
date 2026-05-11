extends Control

var p1 = Process.new("P1", 0, 4, 1) 
var p2 = Process.new("P2", 2, 4, 0)   
var p3 = Process.new("P3", 3, 6, 1) 
var p4 = Process.new("P4", 0, 7, 0) 

var test = [p1, p2, p3, p4]

func _on_button_pressed() -> void:
	var restult = Scheduler._run_priority_rr(test, 2)
	for res in restult:
		print(res)
	
