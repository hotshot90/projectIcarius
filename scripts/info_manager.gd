extends Node

# Singleton for managing information display and distance tracking
signal info_updated(title: String, description: String, distance: float)
signal info_cleared

var player_node: Node2D
var current_element: Node2D = null
var current_element_position: Vector2
var max_distance: float = 200.0  # Maximum distance before clearing info
var last_distance_update: float = 0.0  # Cache last distance to avoid string formatting every frame

# UI references
var info_title: Label
var info_description: Label
var info_distance: Label
var info_panel: Control

func _ready():
	add_to_group("info_manager")
	set_process(true)

func initialize_ui(title_label: Label, desc_label: Label, dist_label: Label, panel: Control):
	info_title = title_label
	info_description = desc_label
	info_distance = dist_label
	info_panel = panel
	
	# Hide panel initially
	hide_info_panel()

func set_player(player: Node2D):
	player_node = player

func show_element_info(element: Node2D, title: String, description: String):
	current_element = element
	if element:
		current_element_position = element.global_position
	
	if info_title:
		info_title.text = title
	if info_description:
		info_description.text = description
	
	# Show the info panel
	show_info_panel()
	
	# Start distance tracking
	update_distance_display()

func clear_info():
	current_element = null
	hide_info_panel()
	emit_signal("info_cleared")

func show_info_panel():
	if info_panel:
		info_panel.visible = true

func hide_info_panel():
	if info_panel:
		info_panel.visible = false

func is_panel_visible() -> bool:
	return info_panel != null and info_panel.visible

func _process(_delta):
	if current_element and player_node:
		# Check if element still exists
		if not is_instance_valid(current_element):
			clear_info()
			return
		
		# Update element position if it moved
		current_element_position = current_element.global_position
		
		# Calculate distance
		var distance = player_node.global_position.distance_to(current_element_position)
		
		# Clear info if too far away
		if distance > max_distance:
			clear_info()
		else:
			update_distance_display()

func update_distance_display():
	if not player_node or not current_element:
		if info_distance:
			info_distance.text = ""  # No distance for inventory items
		return
	
	var distance = player_node.global_position.distance_to(current_element_position)
	
	# Only update UI text if distance changed significantly (reduces string allocations)
	if abs(distance - last_distance_update) > 1.0:
		last_distance_update = distance
		if info_distance:
			info_distance.text = "Distance: %.1f units" % distance
		
		emit_signal("info_updated", info_title.text if info_title else "", 
			info_description.text if info_description else "", distance)

func set_max_distance(distance: float):
	max_distance = distance