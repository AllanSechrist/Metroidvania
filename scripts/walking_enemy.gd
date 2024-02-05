extends CharacterBody2D

const EnemyDeathEffectScene = preload("res://scenes/enemy_death_effect.tscn")

@export var speed = 30.0
@export var turns_at_ledges = true

var gravity = 200
var direction = 1.0

@onready var floor_cast = $FloorCast
@onready var sprite_2d = $Sprite2D
@onready var stats = $Stats
@onready var death_effect_location = $DeathEffectLocation

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
#	if is_on_floor():
	if is_on_wall():
		turn_around()
		
	if is_at_ledge() and turns_at_ledges:
		turn_around()
	# if we set the velocity, there is no need to multiply by delta.
	velocity.x = direction * speed
	sprite_2d.scale.x = direction
	move_and_slide()
	
func is_at_ledge():
	return is_on_floor() and not floor_cast.is_colliding()

func turn_around():
	direction *= -1.0


func _on_hurt_box_hurt(_hitbox, damage):
	stats.health -= damage

func _on_stats_no_health():
	Utils.instantiate_scene_on_world(EnemyDeathEffectScene, death_effect_location.global_position)
	queue_free()
