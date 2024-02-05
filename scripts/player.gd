class_name Player
extends CharacterBody2D

const DustEffectScene = preload("res://scenes/dust_effect.tscn")
const JumpEffectScene = preload("res://effects/jump_effect.tscn")
const WallJumpEffectScene = preload("res://scenes/wall_jump_effect.tscn")

@export var acceleration = 512
@export var max_velocity = 64
@export var friction = 256
@export var air_friction = 64
@export var gravity = 200
@export var jump_force = 128
@export var max_fall_velocity = 128
@export var air_jump_force_reduction = 0.75
@export var wall_slide_speed = 42
@export var max_wall_slide_speed = 128

var air_jump = false
var state = move_state
# states can be used to more easily organize and create logic for
# the game. In this case, it makes it easier to switch between
# the player's different abilities, depending on what the character
# is doing. i.e. moving on the ground vs sliding down a wall.

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var player_blaster = $PlayerBlaster
@onready var fire_rate_timer = $FireRateTimer
@onready var drop_timer = $DropTimer
@onready var camera_2d = $Camera2D
@onready var hurt_box = $HurtBox
@onready var blinking_animation_player = $BlinkingAnimationPlayer
@onready var center = $Center

func _ready():
	PlayerStats.no_health.connect(player_death)
	
func _enter_tree():
	MainInstances.player = self

func _physics_process(delta):
	state.call(delta)
	if Input.is_action_pressed("fire") and fire_rate_timer.time_left == 0:
		fire_rate_timer.start()
		player_blaster.fire_bullet()
		
	if (Input.is_action_pressed("fire_missile") 
	and fire_rate_timer.time_left == 0
	and PlayerStats.missiles > 0):
		fire_rate_timer.start()
		player_blaster.fire_missile()
		PlayerStats.missiles -= 1
		
func _exit_tree():
	MainInstances.player = null
	
# ---------------- STATES -------------------------

func move_state(delta):
	# max_velocity and max_fall_velocity do not need to be multiplied by delta
	# this is because that happens in move_and_slide() and because these
	# two variables represent the max, not the rate of change.
	# gravity, acceleration and friction are all the rate of change so they must be
	# multiplied by delta.
	apply_gravity(delta)
	var input_axis = Input.get_axis("move_left", "move_right")
	if is_moving(input_axis):
		apply_acceleration(delta, input_axis)
	else:	
		apply_friction(delta)
	drop_through_moving_platform_check()
	jump_check()
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >=0
	if just_left_edge:
		coyote_jump_timer.start()
	wall_check()

func wall_slide_state(delta):
	# a "normal" is a vector that points AWAY from a surface.
	# i.e. the left wall is facing RIGHT (1,0)
	# i.e. the right wall is facing LEFT (-1,0)
	var wall_normal = get_wall_normal()
	animation_player.play("wall_slide")
	sprite_2d.scale.x = sign(wall_normal.x)
	velocity.y = clampf(velocity.y, -wall_slide_speed, max_wall_slide_speed)
	wall_jump_check(wall_normal.x)
	apply_wall_slide_gravity(delta)
	move_and_slide()
	wall_detatch(delta, wall_normal.x)
	
# ---------------- END STATES -------------------------

func wall_check():
	if not is_on_floor() and is_on_wall():
		# Here, we omit the () because we want the state variable
		# to point to wall_slide_state, not call it.
		state = wall_slide_state
		air_jump = true
		create_dust_effect()
		
func wall_detatch(delta, wall_axis):
	if Input.is_action_just_pressed("move_right") and wall_axis == 1:
		velocity.x = acceleration * delta
		state = move_state
	if Input.is_action_just_pressed("move_left") and wall_axis == -1:
		velocity.x = -acceleration * delta
		state = move_state
		
	if not is_on_wall() or is_on_floor():
		state = move_state
		
func wall_jump_check(wall_axis):
	if Input.is_action_just_pressed("jump"):
		Sound.play(Sound.jump, randf_range(0.8, 1.1), 5.0)
		velocity.x = wall_axis * max_velocity
		state = move_state
		jump(jump_force * air_jump_force_reduction, false)
		var wall_jump_effect_position = global_position + Vector2(wall_axis * 3.5, -2)
		var wall_jump_effect = Utils.instantiate_scene_on_world(WallJumpEffectScene, wall_jump_effect_position)
		wall_jump_effect.scale.x = wall_axis
		
func apply_wall_slide_gravity(delta):
	var slide_speed = wall_slide_speed
	if Input.is_action_pressed("crouch"):
		slide_speed = max_wall_slide_speed
	velocity.y = move_toward(velocity.y, slide_speed, gravity * delta)
#	
	
	
func drop_through_moving_platform_check():
	if Input.is_action_just_pressed("crouch"):
		set_collision_mask_value(2, false)
		drop_timer.start()

func create_dust_effect():
	Sound.play(Sound.step, randf_range(0.8, 1.1), -10.0)
	Utils.instantiate_scene_on_world(DustEffectScene, global_position)

func is_moving(input_axis):
	return input_axis != 0

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)
		
func apply_acceleration(delta, input_axis):
	velocity.x = move_toward(velocity.x, input_axis * max_velocity, acceleration * delta)
		
func apply_friction(delta):
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, air_friction * delta)
		
func jump_check():
	if is_on_floor():
		air_jump = true
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			jump(jump_force)
	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < -jump_force / 2:
			velocity.y = -jump_force / 2
			
		if Input.is_action_just_pressed("jump") and air_jump:
			jump(jump_force * air_jump_force_reduction)
			air_jump = false
			
func jump(force, create_effect = true):
	Sound.play(Sound.jump, randf_range(0.8, 1.1), 5.0)
	velocity.y = -force
	if create_effect:
		Utils.instantiate_scene_on_world(JumpEffectScene, global_position)
		
func update_animations(input_axis):
	# order maters, having jump last overrides the other animations
	# while the character is in the air.
	sprite_2d.scale.x = sign(get_local_mouse_position().x)
	# checks if scale.x == 0 and forces it to be 1. 
	# if scale.x == 0 a bug happens where the sprite will vanish.
	if abs(sprite_2d.scale.x) != 1 : sprite_2d.scale.x = 1
	if is_moving(input_axis):
		animation_player.play("run")
		# if speed_scale becomes negative, it will play the animation in
		# reverse. input_axis and scale.x will always be either 1 or -1.
		# This is used when the player is moving the opposite way they are facing.
		animation_player.speed_scale = input_axis * sprite_2d.scale.x
	else:
		animation_player.play("idle")
	if not is_on_floor():
		animation_player.play("jump")

func player_death():
	camera_2d.reparent(get_tree().current_scene)
	queue_free()
	Events.player_died.emit()
	
func _on_drop_timer_timeout():
	set_collision_mask_value(2, true)

func _on_hurt_box_hurt(hitbox, damage):
	Sound.play(Sound.hurt)
	Events.add_screenshake.emit(3, 0.25)
	PlayerStats.health -= 1
	blinking_animation_player.play("blink")
#	hurt_box.is_invincible = true
#	await get_tree().create_timer(1.0).timeout
#	hurt_box.is_invincible = false
	
