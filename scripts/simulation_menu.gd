extends Control

var p1 = Process.new("p1", 0, 2)
var p2 = Process.new("p2", 2, 3)
var p3 = Process.new("p3", 3, 5)

var test = [p1, p2, p3]

func _on_button_pressed() -> void:
	var restult = Scheduler._run_fcfs(test)
	for res in restult:
		print(res)
	
