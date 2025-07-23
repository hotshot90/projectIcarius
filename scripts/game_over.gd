# scripts/game_over.gd
extends Control

@onready var score_label = $VBoxContainer/ScoreLabel

func _ready():
	# Get survival time or score from game manager
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("get_survival_time"):
		var survival_time = game_manager.get_survival_time()
		score_label.text = "Survival Time: %.1f seconds" % survival_time
	else:
		score_label.text = "Game Over!"

func _on_restart_button_pressed():
	# Unpause the game and restart
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()