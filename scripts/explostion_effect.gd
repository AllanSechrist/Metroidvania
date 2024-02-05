extends "res://scripts/effect.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	Sound.play(Sound.explosion)
