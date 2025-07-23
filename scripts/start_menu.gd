extends Control

func _ready():
	_focus_start_button()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_button_pressed():
	print("Options button pressed - Not implemented yet")

func _on_quit_button_pressed():
	get_tree().quit()

func _focus_start_button():
	# Use the new path after UI redesign
	var start_button = $MenuPanel/MenuBorder/MenuContent/VBoxContainer/StartButton
	if start_button:
		start_button.grab_focus()
