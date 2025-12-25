extends Node2D

@export var banana_scene: PackedScene
const X_MIN := 55
const X_MAX := 150
const Y_MIN := 225
const Y_MAX := 1375

@export var banana_count := 40  # how many to spawn
@export var y_gaussian_spread := 0.3 # lower = more clustered, higher = more spread

func _ready():
	spawn_gaussian_bananas()

func spawn_gaussian_bananas():
	randomize()
	var y_mean = (Y_MIN + Y_MAX) / 2.0
	var y_dev  = (Y_MAX - Y_MIN) * y_gaussian_spread

	for i in banana_count:
		var banana = banana_scene.instantiate()

		# https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html
		var y = clamp(randfn(y_mean, y_dev), Y_MIN, Y_MAX)
		var x = randf_range(X_MIN, X_MAX)

		banana.position = Vector2(x, y)
		add_child(banana)
