# scripts/triangle_enemy.gd
extends CharacterBody2D

@export var chase_speed := 80.0
@export var health := 1
var player_node: CharacterBody2D

func _ready():
	add_to_group("enemies")
	player_node = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if player_node:
		chase_player()
		move_and_slide()

func chase_player():
	var direction = (player_node.global_position - global_position).normalized()
	velocity = direction * chase_speed

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		# Instant game over
		get_tree().call_group("game_manager", "game_over")