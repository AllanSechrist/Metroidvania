extends ColorRect

# when creating a pause menu or anything like it, it is important to note
# that the process of the Parent node must be set to Always.
# this is because when a node's process is set to Inherit(default setting) it
# will becaome PAUSABLE. This will affect the code of the pause menu
# also PAUSING it, which is, of course, not what we want.
var paused = false :
	set(value):
		paused = value
		get_tree().paused = paused
		visible = paused
		if paused:
			Sound.play(Sound.pause, 1.0, -10.0)
		else:
			Sound.play(Sound.unpause, 1.0, -10.0)
func set_paused(value):
	paused = value

func _process(delta):
	if not MainInstances.player is Player: return
	if Input.is_action_just_pressed("pause"):
		paused = !paused

func _on_resume_button_pressed():
	paused = false
	Sound.play(Sound.click, 1.0, -10.0)

func _on_quit_button_pressed():
	get_tree().quit()

func _on_menu_button_pressed():
	WorldStash.data = {}
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
