extends Control

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed):
		toggle_pause()

func toggle_pause():
	if visible:
		resume_game()
	else:
		pause_game()

func pause_game():
	visible = true
	get_tree().paused = true

func resume_game():
	visible = false
	get_tree().paused = false

func _on_resume_pressed():
	resume_game()

func _on_options_pressed():
	print("Options not implemented yet")

func _on_main_menu_pressed():
	resume_game()
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()