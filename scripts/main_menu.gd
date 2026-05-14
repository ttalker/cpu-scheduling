extends Control


func _on_button_pressed() -> void:
	print("Pressed the simulate button")
	get_tree().change_scene_to_file("res://scenes/simulation_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
