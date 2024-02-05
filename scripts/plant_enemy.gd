extends Node2D

const EnemyBulletScene = preload("res://scenes/enemy_bullet.tscn")
const EnemyDeathEffectScene = preload("res://scenes/enemy_death_effect.tscn")

@export var bullet_speed = 30
@export var spread = 30

@onready var stats = $Stats
@onready var bullet_spawn_point = $BulletSpawnPoint
@onready var fire_direction = $FireDirection
@onready var death_effect_location = $DeathEffectLocation

func fire_bullet():
	# by adding "as Projectile" to the var bullet we are able to have autocomplete for functions
	# this is because we are letting Godot know that "bullet" is related to the Projectile scene.
	# Is is known as casting.
	var bullet = Utils.instantiate_scene_on_world(EnemyBulletScene, bullet_spawn_point.global_position) as Projectile
	var direction = global_position.direction_to(fire_direction.global_position)
	var velocity = direction.normalized() * bullet_speed
	velocity = velocity.rotated(randf_range(-deg_to_rad(spread), deg_to_rad(spread)))
	bullet.velocity = velocity

func _on_hurt_box_hurt(hitbox, damage):
	stats.health -= damage

func _on_stats_no_health():
	Utils.instantiate_scene_on_world(EnemyDeathEffectScene, death_effect_location.global_position)
	queue_free()


