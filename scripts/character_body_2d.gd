extends CharacterBody2D

const SPEED := 100.0
const RUN_SPEED := 100.0
const STOP_SPEED := 60.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@onready var running_sound: AudioStreamPlayer = $"../Sounds/Running"
@onready var slip_sound: AudioStreamPlayer = $"../Sounds/Slip"
@onready var win_sound: AudioStreamPlayer = $"../Sounds/Win"

@export var timer_label: Label

var reached_finish := false
var running := false

var elapsed_time := 0.0
var timer_running := false

var is_slipping := false
var slip_timer := 0.0
const SLIP_DURATION := 3.0
const SLIP_RECOVERY_TIME := 1.0
var slip_recovery_timer := 0.0
var normal_forward_speed: float = RUN_SPEED
var normal_horizontal_speed: float = SPEED

func _ready() -> void:
	normal_forward_speed = RUN_SPEED
	normal_horizontal_speed = SPEED
	
	if timer_label:
		update_timer_display()

func _physics_process(delta: float) -> void:
	
	if not running:
		if Input.is_action_just_pressed("ui_accept"):
			running = true
			timer_running = true
			anim.play("run")
			
			if running_sound and not running_sound.playing:
				running_sound.play()
		else:
			velocity = Vector2.ZERO
			if anim.is_playing():
				anim.stop()
			return

	if reached_finish and timer_running:
		timer_running = false
		
		if running_sound and running_sound.playing:
			running_sound.stop()
		
		if win_sound and not win_sound.playing:
			win_sound.play()

	if timer_running:
		elapsed_time += delta
		update_timer_display()

	if reached_finish:
		velocity = velocity.move_toward(Vector2.ZERO, STOP_SPEED * delta)
		if anim.is_playing():
			anim.stop()
		move_and_slide()
		return

	if is_slipping:
		slip_timer += delta
		if slip_timer >= SLIP_DURATION:
			slip_recovery_timer += delta
			var recovery_progress = min(slip_recovery_timer / SLIP_RECOVERY_TIME, 1.0)
			velocity.y = lerp(RUN_SPEED * 0.5, normal_forward_speed, recovery_progress)
			if recovery_progress >= 1.0:
				is_slipping = false
				slip_timer = 0.0
				slip_recovery_timer = 0.0
		else:
			velocity.y = RUN_SPEED * 0.5
	else:
		velocity.y = normal_forward_speed

	var direction := Input.get_axis("ui_left", "ui_right")
	var current_horizontal_speed := SPEED * 0.5 if is_slipping else normal_horizontal_speed
	velocity.x = direction * current_horizontal_speed

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

func update_timer_display() -> void:
	if timer_label:
		var minutes := int(elapsed_time) / 60
		var seconds := int(elapsed_time) % 60
		var milliseconds := int((elapsed_time - int(elapsed_time)) * 100)
		timer_label.text = "Time: %02d:%02d.%02d" % [minutes, seconds, milliseconds]

func _on_banana_peel_body_entered(peel: Area2D) -> void:
	if not is_slipping or slip_timer >= SLIP_DURATION:
		is_slipping = true
		slip_timer = 0.0
		slip_recovery_timer = 0.0
		
		if slip_sound and not slip_sound.playing:
			slip_sound.play()
		
		print("Slipped on banana!")

func _on_finish_line_body_entered(body: Node2D) -> void:
	if body == self:
		reached_finish = true
		print("Finish reached!")
