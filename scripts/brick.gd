class_name Brick
extends StaticBody2D
# This is being used as a sort of 
# label to help distinguish the Brick from the other static2D
#bodies. Another solution would be to add the brick as a layer
#in project settings, but this is not wise as layers should be
#used for general objects in the game and bricks are unique.
#Also, Godot only has slots for 32 different layers, so we would
#probably run out of layers quickly.

func _ready():
	update_collision_layer()

func update_collision_layer():
	set_collision_layer_value(1, is_visible_in_tree())

func _on_visibility_changed():
	update_collision_layer()
