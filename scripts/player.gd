# scripts/player.gd
extends CharacterBody2D

@export var move_speed := 150.0
var target_position: Vector2
@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
var world_node: Node2D

func _ready():
	add_to_group("player")
	target_position = global_position
	# Find the world node for boundary checking
	world_node = get_tree().get_first_node_in_group("world")
	# Setup camera limits
	setup_camera_limits()

func setup_camera_limits():
	if camera and world_node and world_node.has_method("get_world_bounds"):
		# Wait a frame for world bounds to be calculated
		await get_tree().process_frame
		var bounds = world_node.get_world_bounds()
		if bounds != Rect2():
			camera.limit_left = int(bounds.position.x)
			camera.limit_top = int(bounds.position.y)
			camera.limit_right = int(bounds.position.x + bounds.size.x)
			camera.limit_bottom = int(bounds.position.y + bounds.size.y)
			print("Camera limits set to: ", bounds)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		# Check if target position is within world bounds
		if world_node and world_node.has_method("is_position_in_bounds"):
			if world_node.is_position_in_bounds(mouse_pos):
				target_position = mouse_pos
			else:
				print("Target outside world bounds")
		else:
			target_position = mouse_pos

func _physics_process(_delta):
	var direction = (target_position - global_position).normalized()
	if global_position.distance_to(target_position) > 3.75:
		velocity = direction * move_speed
		move_and_slide()
		update_animation(direction)
	else:
		velocity = Vector2.ZERO
		if animated_sprite:
			animated_sprite.stop()

func update_animation(direction: Vector2):
	if not animated_sprite:
		return
	
	# Determine direction for animation
	var angle = direction.angle()
	
	# Use run animation for movement (can map to walk_* for directional)
	# For now, use the "run" animation from the Steamboat Willie pack
	if velocity.length() > 0:
		animated_sprite.animation = "run"
		
		# Flip sprite based on direction
		if angle > PI/2 or angle < -PI/2:
			animated_sprite.flip_h = true  # Moving left
		else:
			animated_sprite.flip_h = false  # Moving right
	else:
		animated_sprite.animation = "idle"
	
	animated_sprite.play()
