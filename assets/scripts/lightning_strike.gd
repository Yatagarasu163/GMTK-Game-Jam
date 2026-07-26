extends Node2D

func _on_area_2d_area_entered(area: Area2D) -> void:
	var collider = area.get_parent();
	if collider.is_in_group("PLAYER"):
		if collider.lives_left > 0:
			if collider.lives_left > 1:
				collider.is_hit();
			else:
				collider.is_die();
			collider.lives_left -= 1;
			print(collider.lives_left);
