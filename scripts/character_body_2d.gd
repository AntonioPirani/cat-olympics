extends CharacterBody2D

# Movement speeds
const SPEED := 100.0         # horizontal
const RUN_SPEED := 100.0     # forward

# Smooth stop multiplier
const STOP_SPEED := 60.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Flag to indicate player reached finish
var reached_finish := false

func _physics_process(delta: float) -> void:
	if reached_finish:
		# Smoothly stop both horizontal and vertical movement
		velocity = velocity.move_toward(Vector2.ZERO, STOP_SPEED * delta)
		if anim.is_playing():
			anim.stop()
			
	else:
		# Normal movement
		velocity.y = RUN_SPEED
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


func _on_finish_line_body_entered(body: Node2D) -> void:
	if body == self:
		reached_finish = true
		print("Finish reached!")
