extends Area2D

func _ready():
	body_entered.connect(_on_banana_peel_body_entered)

func _on_banana_peel_body_entered(body):
	if body is CharacterBody2D:
		print("Player slipped on banana!")
		
		queue_free()
