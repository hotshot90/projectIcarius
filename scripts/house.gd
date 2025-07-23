# THIS FILE IS DEPRECATED - USE scripts/entities/Base.gd INSTEAD
# This file is kept temporarily for compatibility but should be removed after migration

class_name DeprecatedHouse
extends Area2D

## DEPRECATED: Use Base.gd instead
## This is a placeholder to prevent errors during migration

var info_manager: Node

func _ready():
	print("WARNING: Using deprecated house.gd - switch to Base.gd entity system")
	
	# Create collision shape for backward compatibility
	var collision_shape = $CollisionShape2D
	if collision_shape:
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = Vector2(150, 120)
		collision_shape.shape = rect_shape
		collision_shape.position = Vector2(0, -10)
	
	# Make sure Area2D is pickable
	input_pickable = true
	z_index = 0
	
	# Find info manager
	call_deferred("find_info_manager")

func find_info_manager():
	info_manager = get_tree().get_first_node_in_group("info_manager")
	if not info_manager:
		print("Warning: InfoManager not found!")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		show_house_info()
		get_viewport().set_input_as_handled()

func show_house_info():
	print("Base clicked!")
	if info_manager:
		var description = "Your primary base of operations."
		info_manager.show_element_info(self, "Main Base", description)
	else:
		print("InfoManager not found!")

# Remove all old inventory/rest/store functionality - these are no longer supported
func _input(_event):
	# No longer handles input events for inventory/rest/store
	pass
