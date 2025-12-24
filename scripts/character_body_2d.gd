extends CharacterBody2D

const SPEED := 300.0        # left/right speed
const RUN_SPEED := 200.0    # forward (down) speed

func _physics_process(delta: float) -> void:
	# Always move downward
	velocity.y = RUN_SPEED

	# Left / Right movement
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
