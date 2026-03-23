extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var jump: AudioStreamPlayer = $Sounds/Jump

var is_died: bool = false

func _physics_process(delta: float) -> void:
	if not is_died:
		physics_process_alive(delta)
	else:
		physics_process_died(delta)
	move_and_slide()

func physics_process_alive(delta:float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func physics_process_died(delta: float) -> void:
	velocity.y += gravity * delta
	animated_sprite.play("died")

func died():	
	is_died = true
	Engine.time_scale = 0.5
	velocity.y = JUMP_VELOCITY
	velocity.x = 0
	collision_shape.queue_free()
	animation_player.play("died")

func restart():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
	queue_free()
