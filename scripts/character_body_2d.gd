extends CharacterBody2D

const SPEED := 100.0          # horizontal
const RUN_SPEED := 100.0      # forward (vertical) normal
const STOP_SPEED := 60.0      # smooth stop at finish

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var reached_finish := false
var running := false

# Slip effect variables
var is_slipping := false
var slip_timer := 0.0
const SLIP_DURATION := 3.0    # seconds slowed
const SLIP_RECOVERY_TIME := 1.0  # seconds to smoothly recover
var slip_recovery_timer := 0.0
var normal_forward_speed: float = RUN_SPEED
var normal_horizontal_speed: float = SPEED

func _ready() -> void:
	# Store normals (in case you ever change constants)
	normal_forward_speed = RUN_SPEED
	normal_horizontal_speed = SPEED

func _physics_process(delta: float) -> void:
	# Start running on SPACE
	if not running:
		if Input.is_action_just_pressed("ui_accept"):
			running = true
			anim.play("run")
		else:
			velocity = Vector2.ZERO
			if anim.is_playing():
				anim.stop()
			return

	# Handle finish line smooth stop
	if reached_finish:
		velocity = velocity.move_toward(Vector2.ZERO, STOP_SPEED * delta)
		if anim.is_playing():
			anim.stop()
		move_and_slide()
		return

	# --- Slip effect logic ---
	if is_slipping:
		slip_timer += delta

		# After the slip duration, start recovering smoothly
		if slip_timer >= SLIP_DURATION:
			slip_recovery_timer += delta
			var recovery_progress = min(slip_recovery_timer / SLIP_RECOVERY_TIME, 1.0)
			# Lerp back to normal speeds
			velocity.y = lerp(RUN_SPEED * 0.5, normal_forward_speed, recovery_progress)

			if recovery_progress >= 1.0:
				is_slipping = false
				slip_timer = 0.0
				slip_recovery_timer = 0.0
		else:
			# During the 3-second slip, keep reduced forward speed
			velocity.y = RUN_SPEED * 0.5
	else:
		# Normal forward speed
		velocity.y = normal_forward_speed

		# Horizontal movement (also reduced during slip)
	var direction := Input.get_axis("ui_left", "ui_right")
	var current_horizontal_speed := SPEED * 0.5 if is_slipping else normal_horizontal_speed
	velocity.x = direction * current_horizontal_speed
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

# Collision with banana peel
func _on_banana_peel_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body == self:  # adjust check if needed
		is_slipping = true
		slip_timer = 0.0
		slip_recovery_timer = 0.0
		# Optional: remove the peel
		get_parent().get_node("BananaPeel").queue_free()
		print("Slipped on banana!")

func _on_finish_line_body_entered(body: Node2D) -> void:
	if body == self:
		reached_finish = true
		print("Finish reached!")
