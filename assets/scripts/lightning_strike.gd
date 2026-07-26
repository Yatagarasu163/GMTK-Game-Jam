extends Node2D

var state_checker;

func _ready() -> void:
	state_checker = get_tree().get_first_node_in_group("state_checker");

func _on_area_2d_area_entered(area: Area2D) -> void:
	var collider = area.get_parent();
	if collider.is_in_group("PLAYER"):
		if collider.lives_left > 0:
			if collider.lives_left > 1:
				collider.is_hit();
			else:
				collider.is_die();
			collider.lives_left -= 1;
			visible = false;
			await get_tree().create_timer(2.0).timeout;
			state_checker.check_game_state();
