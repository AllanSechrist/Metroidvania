extends Control

@onready var full = $Full
@onready var empty = $Empty

# Called when the node enters the scene tree for the first time.
func _ready():
	update_health_ui()
	update_max_health_ui()
	PlayerStats.health_changed.connect(update_health_ui)
	PlayerStats.max_health_changed.connect(update_max_health_ui)

func update_health_ui():
	full.size.x = PlayerStats.health * 5 + 1
	empty.size.x = PlayerStats.max_health * 5 + 1
	
func update_max_health_ui():
	empty.size.x = PlayerStats.max_health * 5 + 1
