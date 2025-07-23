extends Control

@onready var player_dot = $Border/MapArea/PlayerDot
@onready var map_area = $Border/MapArea
@onready var terrain_display = $Border/MapArea/TerrainDisplay

var player_node: Node2D
var world_node: Node2D
var world_bounds: Rect2
var grid_node: Node2D
var terrain_texture: ImageTexture

func _ready():
	# Find player and world nodes
	player_node = get_tree().get_first_node_in_group("player")
	world_node = get_tree().get_first_node_in_group("world")
	
	if world_node and world_node.has_method("get_world_bounds"):
		# Wait a frame for world bounds to be calculated
		await get_tree().process_frame
		world_bounds = world_node.get_world_bounds()
		grid_node = world_node.get_grid()
		generate_terrain_minimap()
		print("Minimap world bounds: ", world_bounds)

func _process(_delta):
	update_player_position()

func generate_terrain_minimap():
	if not grid_node or not grid_node.has_method("get_terrain_value") or not terrain_display:
		print("Minimap: Missing required nodes for terrain generation")
		return
	
	# Create a smaller version of the terrain for the minimap
	var minimap_size = 100  # 100x100 pixel minimap
	var image = Image.create(minimap_size, minimap_size, false, Image.FORMAT_RGB8)
	
	# Sample the terrain at lower resolution
	var grid_width = 400  # From isometric_grid.gd
	var grid_height = 300
	
	for y in range(minimap_size):
		for x in range(minimap_size):
			# Map minimap pixel to grid coordinates
			var grid_x = int((float(x) / minimap_size) * grid_width)
			var grid_y = int((float(y) / minimap_size) * grid_height)
			
			# Get terrain value and convert to color
			var terrain_value = grid_node.get_terrain_value(grid_x, grid_y)
			var color = get_minimap_terrain_color(terrain_value)
			image.set_pixel(x, y, color)
	
	# Create texture from image
	terrain_texture = ImageTexture.create_from_image(image)
	
	# Apply texture to terrain display
	if terrain_display and terrain_texture:
		terrain_display.texture = terrain_texture

func get_minimap_terrain_color(terrain_value: float) -> Color:
	if terrain_value < 0.4:
		# Desert terrain - sandy brown
		return Color(0.8, 0.7, 0.4)
	else:
		# Grass terrain - green
		return Color(0.3, 0.6, 0.2)

func update_player_position():
	if not player_node or not map_area or not player_dot:
		return
	
	if world_bounds == Rect2():
		return
	
	# Get player position relative to world bounds
	var player_pos = player_node.global_position
	var relative_x = (player_pos.x - world_bounds.position.x) / world_bounds.size.x
	var relative_y = (player_pos.y - world_bounds.position.y) / world_bounds.size.y
	
	# Clamp to 0-1 range
	relative_x = clamp(relative_x, 0.0, 1.0)
	relative_y = clamp(relative_y, 0.0, 1.0)
	
	# Convert to minimap coordinates
	var map_size = map_area.size
	var map_x = relative_x * map_size.x
	var map_y = relative_y * map_size.y
	
	# Update player dot position (centered on the calculated position)
	player_dot.position = Vector2(map_x - 2, map_y - 2)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Allow clicking on minimap to move player
		handle_minimap_click(event.position)

func handle_minimap_click(click_pos: Vector2):
	if not player_node or not map_area:
		return
	
	if world_bounds == Rect2():
		return
	
	# Convert click position to relative coordinates within map area
	var local_pos = click_pos - map_area.position
	var relative_x = local_pos.x / map_area.size.x
	var relative_y = local_pos.y / map_area.size.y
	
	# Clamp to valid range
	relative_x = clamp(relative_x, 0.0, 1.0)
	relative_y = clamp(relative_y, 0.0, 1.0)
	
	# Convert to world coordinates
	var world_x = world_bounds.position.x + (relative_x * world_bounds.size.x)
	var world_y = world_bounds.position.y + (relative_y * world_bounds.size.y)
	var target_pos = Vector2(world_x, world_y)
	
	# Set player target position (assuming player has this property)
	if player_node.has_method("set_target_position"):
		player_node.set_target_position(target_pos)
	elif "target_position" in player_node:
		player_node.target_position = target_pos
