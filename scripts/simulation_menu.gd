extends Control

var p1 = Process.new("P1", 0, 4)   # arrives at 0, burst 4
var p2 = Process.new("P2", 2, 1)   # arrives at 3, burst 1

var test = [p1, p2]

func _on_button_pressed() -> void:
	var restult = Scheduler._run_rr(test, 2)
	for res in restult:
		print(res)
	
