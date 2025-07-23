class_name Player
extends CharacterBody2D

## Player character entity
## Handles movement and basic interactions

@export var move_speed: float = 150.0
var target_position: Vector2
@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
var world_node: Node2D

func _ready() -> void:
	add_to_group("entities")
	add_to_group("player")
	
	target_position = global_position
	z_index = 1  # Ensure player is drawn on top of buildings
	
	# Find the world node for boundary checking
	world_node = get_tree().get_first_node_in_group("world")
	_setup_camera()

func _setup_camera() -> void:
	if camera:
		camera.enabled = true
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 3.0
		
		# Setup camera limits if world exists
		if world_node and world_node.has_method("get_world_bounds"):
			await get_tree().process_frame
			var bounds = world_node.get_world_bounds()
			if bounds != Rect2():
				camera.limit_left = int(bounds.position.x)
				camera.limit_top = int(bounds.position.y)
				camera.limit_right = int(bounds.position.x + bounds.size.x)
				camera.limit_bottom = int(bounds.position.y + bounds.size.y)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Don't move if input was already handled
		if event.is_echo() or get_viewport().is_input_handled():
			return
		
		_handle_movement_input(event)

func _handle_movement_input(event: InputEventMouseButton) -> void:
	# Check if we clicked on any interactive entities
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collision_mask = 0xFFFFFFFF
	
	var results = space_state.intersect_point(query)
	
	# Check if we clicked on any Area2D (entities)
	var clicked_on_entity = false
	for result in results:
		if result.collider is Area2D:
			clicked_on_entity = true
			break
	
	# Only move if we didn't click on an entity
	if not clicked_on_entity:
		var mouse_pos = get_global_mouse_position()
		# Check if target position is within world bounds
		if world_node and world_node.has_method("is_position_in_bounds"):
			if world_node.is_position_in_bounds(mouse_pos):
				target_position = mouse_pos
			else:
				print("Target outside world bounds")
		else:
			target_position = mouse_pos

func _physics_process(_delta: float) -> void:
	var direction = (target_position - global_position).normalized()
	if global_position.distance_to(target_position) > 5.0:
		velocity = direction * move_speed
		move_and_slide()
		_update_animation(direction)
	else:
		velocity = Vector2.ZERO
		if animated_sprite:
			animated_sprite.stop()

func _update_animation(direction: Vector2) -> void:
	if not animated_sprite:
		return
	
	var angle = direction.angle()
	
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

func set_target_position(pos: Vector2) -> void:
	# Allow external systems (like minimap) to set target position
	if world_node and world_node.has_method("is_position_in_bounds"):
		if world_node.is_position_in_bounds(pos):
			target_position = pos
		else:
			print("Target outside world bounds")
	else:
		target_position = pos