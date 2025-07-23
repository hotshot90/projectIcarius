# scripts/game_manager.gd
extends Node

@export var triangle_spawn_interval := 2.0
@export var spawn_distance := 400.0
var triangle_scene = preload("res://scenes/triangle_enemy.tscn")
var game_over_scene = preload("res://scenes/game_over.tscn")
var player_node: CharacterBody2D
var spawn_timer: Timer
var survival_start_time: float
var is_game_over := false

func _ready():
	add_to_group("game_manager")
	player_node = get_tree().get_first_node_in_group("player")
	survival_start_time = Time.get_unix_time_from_system()
	
	# Setup spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = triangle_spawn_interval
	spawn_timer.timeout.connect(spawn_triangle_swarm)
	spawn_timer.autostart = true
	add_child(spawn_timer)

func spawn_triangle_swarm():
	# Spawn 3-5 triangles at random positions around the player
	var num_triangles = randi_range(3, 5)
	for i in range(num_triangles):
		spawn_triangle()

func spawn_triangle():
	if triangle_scene and player_node:
		var triangle = triangle_scene.instantiate()
		get_parent().add_child(triangle)
		
		# Spawn at random position around player
		var angle = randf() * TAU
		var spawn_pos = player_node.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance
		triangle.global_position = spawn_pos

func game_over():
	if is_game_over:
		return
	
	is_game_over = true
	print("Game Over!")
	
	# Stop spawning enemies
	if spawn_timer:
		spawn_timer.stop()
	
	# Show game over screen
	if game_over_scene:
		var game_over_instance = game_over_scene.instantiate()
		get_tree().current_scene.add_child(game_over_instance)
		get_tree().paused = true

func get_survival_time() -> float:
	var current_time = Time.get_unix_time_from_system()
	return current_time - survival_start_time
