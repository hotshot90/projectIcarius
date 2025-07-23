extends Control

func _ready():
	grab_focus()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_button_pressed():
	print("Options button pressed - Not implemented yet")

func _on_quit_button_pressed():
	get_tree().quit()

func grab_focus():
	$VBoxContainer/StartButton.grab_focus()