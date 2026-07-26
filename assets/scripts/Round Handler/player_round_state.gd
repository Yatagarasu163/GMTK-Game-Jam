extends Node

signal state_reset(
	movement_points: int,
	lightning_rods: int
)

signal movement_points_changed(
	current: int,
	maximum: int
)

signal lightning_rods_changed(
	current: int,
	maximum: int
)


@export_range(0, 100, 1) var max_movement_points: int = 5
@export_range(0, 100, 1) var max_lightning_rods: int = 2


var movement_points: int = 0
var lightning_rods: int = 0


func _ready() -> void:
	reset_for_new_round()


func reset_for_new_round() -> void:
	movement_points = max_movement_points
	lightning_rods = max_lightning_rods

	movement_points_changed.emit(
		movement_points,
		max_movement_points
	)

	lightning_rods_changed.emit(
		lightning_rods,
		max_lightning_rods
	)

	state_reset.emit(
		movement_points,
		lightning_rods
	)

	print(
		"Player state reset — Movement: ",
		movement_points,
		", Rods: ",
		lightning_rods
	)
