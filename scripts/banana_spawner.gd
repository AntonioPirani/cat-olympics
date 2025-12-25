extends Node2D

@export var banana_scene: PackedScene
@export var player: NodePath  # Drag your Player node here in the editor

const X_MIN := 55
const X_MAX := 150
const Y_MIN := 225
const Y_MAX := 1375

@export var banana_count := 30  # how many to spawn
@export var y_gaussian_spread := 0.5  # lower = more clustered, higher = more spread

var player_node: CharacterBody2D  # Store the player reference

func _ready() -> void:
	player_node = get_node(player) as CharacterBody2D
	if player_node == null:
		push_error("Player node not found! Assign it in the inspector.")
		return
	spawn_gaussian_bananas()

func spawn_gaussian_bananas() -> void:
	randomize()
	var y_mean = (Y_MIN + Y_MAX) / 2.0
	var y_dev = (Y_MAX - Y_MIN) * y_gaussian_spread

	for i in banana_count:
		var banana: Area2D = banana_scene.instantiate()
		
		# Position
		var y = clamp(randfn(y_mean, y_dev), Y_MIN, Y_MAX)
		var x = randf_range(X_MIN, X_MAX)
		banana.position = Vector2(x, y)
		
		# Add to scene
		add_child(banana)
		
		# Connect body_entered signal to a local handler
		banana.body_entered.connect(_on_banana_body_entered.bind(banana))

func _on_banana_body_entered(body: Node2D, banana: Area2D) -> void:
	if body == player_node:
		# Call player's slip function
		player_node._on_banana_peel_body_entered(banana)
		# Remove the peel
		banana.queue_free()
