extends Node

const TEST_PATH = "res://save.txt"
const PROD_PATH = "user://metroidvania_save.save"

var save_path = TEST_PATH
var is_loading = false

func save_game():
	WorldStash.stash("level", "file_path", MainInstances.level.scene_file_path)
	WorldStash.stash("player", "x", MainInstances.player.global_position.x)
	WorldStash.stash("player", "y", MainInstances.player.global_position.y)
	PlayerStats.stash_stats()
	
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	var world_stash_data_string = JSON.stringify(WorldStash.data)
	# store string vs store line
	# store string saves all the data as one string in the save file
	# including and new data you wish to save.
	# store line will save any new data to its own line
	# since we are only going to save data from WorldStash
	# it may be better just to use store string.
	save_file.store_string(world_stash_data_string)
	save_file.close()

func load_game():
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	if not save_file is FileAccess: return null
	
	var world_stash_data = JSON.parse_string(save_file.get_line())
	WorldStash.data = world_stash_data
	
	var file_path = WorldStash.retrieve("level", "file_path")
	MainInstances.world.load_level(file_path)
	var player_x = WorldStash.retrieve("player", "x")
	var player_y = WorldStash.retrieve("player", "y")
	MainInstances.player.global_position = Vector2(player_x, player_y)
	PlayerStats.retrieve_stats()
	save_file.close()
