extends CharacterBody2D

const SPEED := 100.0         # horizontal
const RUN_SPEED := 100.0     # vertical
const STOP_SPEED := 60.0    # smooth stop speed

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var reached_finish := false
var running := false           # Has the player started?

func _physics_process(delta: float) -> void:
	# Start running on SPACE
	if not running:
		if Input.is_action_just_pressed("ui_accept"):  # default SPACE
			running = true
			anim.play("run")  # Start the run animation when SPACE is pressed
		else:
			# Show NO animation (or an idle animation) while waiting
			velocity = Vector2.ZERO
			if anim.is_playing():
				anim.stop()  # Ensure no animation plays before SPACE
			return

	# Handle finish line smooth stop
	if reached_finish:
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
			play_anim("run")  # moving straight

	move_and_slide()

func play_anim(name: String) -> void:
	if anim.animation != name:
		anim.play(name)

func _on_finish_line_body_entered(body: Node2D) -> void:
	if body == self:
		reached_finish = true
		print("Finish reached!")
