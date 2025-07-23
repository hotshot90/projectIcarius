# scripts/laser.gd
extends Area2D

@export var speed := 300.0
@export var damage := 20
var direction: Vector2
var lifetime := 3.0

func _ready():
	# Connect to area entered signal
	body_entered.connect(_on_body_entered)
	# Destroy laser after lifetime
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.timeout.connect(queue_free)
	timer.one_shot = true
	add_child(timer)
	timer.start()

func set_target(target_position: Vector2):
	direction = (target_position - global_position).normalized()

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()