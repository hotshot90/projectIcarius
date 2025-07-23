# scripts/square_npc.gd
extends CharacterBody2D

@export var detection_radius := 150.0
@export var laser_damage := 20
var player_node: CharacterBody2D
var laser_scene = preload("res://scenes/laser.tscn")

func _ready():
	# Find the player node
	player_node = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if player_node:
		var distance_to_player = global_position.distance_to(player_node.global_position)
		if distance_to_player <= detection_radius:
			shoot_at_nearby_enemies()

func shoot_at_nearby_enemies():
	# Find enemies (triangles) near the player
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var distance_to_enemy = player_node.global_position.distance_to(enemy.global_position)
		if distance_to_enemy <= detection_radius:
			shoot_laser(enemy.global_position)
			break  # Only shoot at one enemy at a time

func shoot_laser(target_position: Vector2):
	if laser_scene:
		var laser = laser_scene.instantiate()
		get_parent().add_child(laser)
		laser.global_position = global_position
		laser.set_target(target_position)