extends AnimatedSprite2D


func _ready():
	# You want to pass in a reference to the function you want to use
	# not the actual function i.e. queue_free() <-- is incorrect
	# because you will pass the return value of queue_free()
	# not the function itself.
	animation_finished.connect(queue_free)
