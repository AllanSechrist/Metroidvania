extends Node

func instantiate_scene_on_world(scene : PackedScene, position : Vector2):
	# gets parent of the scene this function is called in
	var world = get_tree().current_scene
	# create the passed in scene
	var instance = scene.instantiate()
	# add new scene to root node and create it at passed in position
	world.add_child.call_deferred(instance)
	instance.global_position = position
	return instance
