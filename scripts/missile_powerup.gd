extends Powerup


func pick_up():
	super()
	PlayerStats.max_missiles += 3
	PlayerStats.missiles = PlayerStats.max_missiles
