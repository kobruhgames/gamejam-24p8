extends Panel

func _on_player_body_health_lost(new_health):
	$Label.text = "HEALTH: " + str(new_health)
