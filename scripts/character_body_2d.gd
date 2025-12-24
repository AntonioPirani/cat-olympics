extends CharacterBody2D

const SPEED := 10.0
const RUN_SPEED := 200.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Always move downward
	velocity.y = RUN_SPEED

	# Horizontal input
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	# Animation logic
	if direction < 0:
		play_anim("turn_left")
	elif direction > 0:
		play_anim("turn_right")
	else:
		play_anim("run")

	move_and_slide()


func play_anim(name: String) -> void:
	if anim.animation != name:
		anim.play(name)
