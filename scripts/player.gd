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
	# Ensure player is drawn on top of buildings
	z_index = 1
	# Enable smooth camera following
	if camera:
		camera.enabled = true
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 3.0

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
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Don't move if input was already handled (by UI or buildings)
		if event.is_echo() or get_viewport().is_input_handled():
			return
			
		# Don't block movement for info panel anymore - player can move while base info is shown
		
		# Check if we clicked on a UI element or building
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = get_global_mouse_position()
		query.collision_mask = 0xFFFFFFFF  # Check all layers
		
		var results = space_state.intersect_point(query)
		
		# Check if we clicked on any Area2D (buildings, interactables)
		var clicked_on_building = false
		for result in results:
			if result.collider is Area2D:
				clicked_on_building = true
				break
		
		# Only move if we didn't click on a building
		if not clicked_on_building:
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
	if global_position.distance_to(target_position) > 5.0:
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
			animated_sprite.flip_h = false  # Moving left
		else:
			animated_sprite.flip_h = true  # Moving right
	else:
		animated_sprite.animation = "idle"
	
	animated_sprite.play()

func set_target_position(pos: Vector2):
	# Allow external systems (like minimap) to set target position
	if world_node and world_node.has_method("is_position_in_bounds"):
		if world_node.is_position_in_bounds(pos):
			target_position = pos
		else:
			print("Target outside world bounds")
	else:
		target_position = pos
