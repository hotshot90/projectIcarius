# Project Cleanup Notes

## Files to Remove (Old/Placeholder Features)

### Old House System
- `scenes/house.tscn` (replaced by `scenes/entities/Base.tscn`)
- `scripts/house.gd` (replaced by `scripts/entities/Base.gd`)
- `scenes/house_options_menu.tscn` (placeholder feature removed)
- `scripts/house_options_menu.gd` (placeholder feature removed)

### Old Inventory System
- `scenes/inventory.tscn` (placeholder feature removed)
- `scripts/inventory.gd` (placeholder feature removed)

### Old Main Scene
- `scenes/main.tscn` (replaced by `scenes/Game.tscn`)
- `scenes/improved_main.tscn` (replaced by `scenes/Game.tscn`)
- `scripts/main.gd` (replaced by `scripts/Game.gd`)

### Old Pause Menu
- `scenes/pause_menu.tscn` (will be recreated with new UI system)
- `scripts/pause_menu.gd` (will be recreated with new UI system)

## New Clean Architecture

### Core Systems
- `scripts/core/GameManager.gd` - Central game state management
- `scripts/core/SceneManager.gd` - Scene transitions
- `scripts/core/EntityManager.gd` - Entity management with spatial optimization
- `scripts/core/InputManager.gd` - Centralized input handling
- `scripts/ui/UIManager.gd` - UI management with theming

### Entities
- `scripts/entities/BaseEntity.gd` - Base class for all game entities
- `scripts/entities/Player.gd` - Clean player implementation
- `scripts/entities/Base.gd` - Clean base building implementation

### UI Components
- `scripts/ui/MainMenu.gd` - Clean main menu
- `scripts/ui/InfoPanel.gd` - Simple info display panel

### Game Scene
- `scenes/Game.tscn` - Main game scene
- `scripts/Game.gd` - Game scene controller

## Configuration Required

Add these to Project Settings > AutoLoad:
1. GameManager: `res://scripts/core/GameManager.gd`
2. SceneManager: `res://scripts/core/SceneManager.gd` 
3. EntityManager: `res://scripts/core/EntityManager.gd`
4. InputManager: `res://scripts/core/InputManager.gd`
5. UIManager: `res://scripts/ui/UIManager.gd`