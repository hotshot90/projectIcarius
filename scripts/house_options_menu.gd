extends Control

signal menu_closed

var inventory_scene = preload("res://scenes/inventory.tscn")

func _ready():
	# Make sure the menu is visible and receives input
	set_process_input(true)

func _input(event):
	# Close menu when clicking outside
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var menu_rect = Rect2(global_position, size)
		if not menu_rect.has_point(mouse_pos):
			close_menu()

func _on_inventory_button_pressed():
	show_inventory()
	close_menu()

func _on_rest_button_pressed():
	print("Player rested and recovered health!")
	close_menu()

func _on_store_button_pressed():
	print("Store items functionality - Not implemented yet")
	close_menu()

func _on_close_button_pressed():
	close_menu()

func show_inventory():
	var inventory_instance = inventory_scene.instantiate()
	get_tree().current_scene.add_child(inventory_instance)

func close_menu():
	emit_signal("menu_closed")
	queue_free()