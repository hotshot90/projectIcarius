extends Control

@onready var item_grid = $InventoryPanel/PanelBorder/InnerPanel/VBoxContainer/ItemGrid
@onready var close_button = $InventoryPanel/PanelBorder/InnerPanel/VBoxContainer/HeaderPanel/CloseButton

var info_manager: Node
var selected_slot: Control = null

# Inventory data - starts empty
var inventory_items = []

func _ready():
	# Find info manager
	info_manager = get_tree().get_first_node_in_group("info_manager")
	populate_inventory()
	set_process_input(true)
	
	# Connect close button if it exists
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)

func _input(event):
	# Close inventory with Escape key
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close_inventory()
	
	# Close inventory when clicking outside the panel
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var panel_rect = Rect2($InventoryPanel.global_position, $InventoryPanel.size)
		if not panel_rect.has_point(mouse_pos):
			close_inventory()

func populate_inventory():
	# Clear existing items
	for child in item_grid.get_children():
		child.queue_free()
	
	# Create item slots (6x5 grid = 30 slots)
	for i in range(30):
		var item_slot = create_item_slot()
		item_grid.add_child(item_slot)
		
		# Add sample items to first few slots
		if i < inventory_items.size():
			populate_item_slot(item_slot, inventory_items[i])

func create_item_slot() -> Control:
	var slot = Button.new()
	slot.custom_minimum_size = Vector2(60, 60)
	slot.flat = true
	
	# Slot background
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.4, 0.4, 0.5, 1)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(bg)
	
	# Slot border
	var border = ColorRect.new()
	border.name = "Border"
	border.anchor_right = 1.0
	border.anchor_bottom = 1.0
	border.color = Color(0.6, 0.6, 0.7, 1)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(border)
	
	# Inner area
	var inner = ColorRect.new()
	inner.name = "Inner"
	inner.anchor_left = 0.1
	inner.anchor_top = 0.1
	inner.anchor_right = 0.9
	inner.anchor_bottom = 0.9
	inner.color = Color(0.3, 0.3, 0.4, 1)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(inner)
	
	# Selection highlight (hidden by default)
	var highlight = ColorRect.new()
	highlight.name = "Highlight"
	highlight.anchor_right = 1.0
	highlight.anchor_bottom = 1.0
	highlight.color = Color(1, 1, 0, 0.3)
	highlight.visible = false
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(highlight)
	
	return slot

func populate_item_slot(slot: Control, item_data: Dictionary):
	# Add item icon/text
	var label = Label.new()
	label.text = item_data.icon if "icon" in item_data else "?"
	label.anchor_left = 0.5
	label.anchor_top = 0.5
	label.anchor_right = 0.5
	label.anchor_bottom = 0.5
	label.position = Vector2(-10, -10)
	label.size = Vector2(20, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(label)
	
	# Store item data on the slot
	slot.set_meta("item_data", item_data)
	
	# Connect click event
	if slot is Button:
		slot.pressed.connect(_on_item_slot_clicked.bind(slot))

func _on_item_slot_clicked(slot: Control):
	# Update selection
	if selected_slot:
		var old_highlight = selected_slot.get_node_or_null("Highlight")
		if old_highlight:
			old_highlight.visible = false
	
	selected_slot = slot
	var highlight = slot.get_node_or_null("Highlight")
	if highlight:
		highlight.visible = true
	
	# Get item data and show in info panel
	var item_data = slot.get_meta("item_data", null)
	if item_data and info_manager:
		var full_description = item_data.description
		if "stats" in item_data:
			full_description += "\n\n" + item_data.stats
		info_manager.show_element_info(null, item_data.name, full_description)

func close_inventory():
	queue_free()
	
func _on_close_button_pressed():
	close_inventory()
