extends Node2D


@export var tilemap: TileMapLayer
@export var lightning_scene: PackedScene

# Safety limit so scanning cannot continue forever.
@export_range(1, 100, 1) var maximum_scan_tiles: int = 30

@export var show_debug_messages: bool = true


var spawned_lightning: Array[Node2D] = []


func cast_lightning(rod: Node2D) -> void:
	if tilemap == null:
		push_error("Lightning Manager does not have a TileMap assigned.")
		return

	if lightning_scene == null:
		push_error("Lightning Manager does not have a lightning scene assigned.")
		return

	_clear_previous_lightning()

	var start_cell: Vector2i = tilemap.local_to_map(
		tilemap.to_local(rod.global_position)
	)

	# Always place lightning directly on the rod that activated it.
	_spawn_lightning_at_cell(start_cell, Vector2i.RIGHT)

	check_direction(start_cell, Vector2i.RIGHT, rod)
	check_direction(start_cell, Vector2i.LEFT, rod)
	check_direction(start_cell, Vector2i.UP, rod)
	check_direction(start_cell, Vector2i.DOWN, rod)


func check_direction(
	start_cell: Vector2i,
	direction: Vector2i,
	original_rod: Node2D
) -> void:
	for distance: int in range(1, maximum_scan_tiles + 1):
		var current_cell: Vector2i = start_cell + direction * distance

		if show_debug_messages:
			print("Checking cell: ", current_cell)

		# Walls stop the lightning.
		if is_wall(current_cell):
			if show_debug_messages:
				print("Lightning stopped by wall at: ", current_cell)

			return

		# When another rod is found, create lightning between both rods.
		if get_rod_at_cell(current_cell, original_rod) != null:
			if show_debug_messages:
				print("Connected rod found at: ", current_cell)

			_spawn_lightning_line(
				start_cell,
				current_cell,
				direction
			)

			return

	if show_debug_messages:
		print(
			"No rod or wall found within ",
			maximum_scan_tiles,
			" tiles."
		)


func _spawn_lightning_line(
	start_cell: Vector2i,
	end_cell: Vector2i,
	direction: Vector2i
) -> void:
	# Start one tile away because the starting rod already has lightning.
	var current_cell: Vector2i = start_cell + direction

	while true:
		_spawn_lightning_at_cell(current_cell, direction)

		# Includes lightning directly on the detected rod.
		if current_cell == end_cell:
			break

		current_cell += direction


func _spawn_lightning_at_cell(
	cell: Vector2i,
	direction: Vector2i
) -> void:
	var lightning_instance := lightning_scene.instantiate() as Node2D

	if lightning_instance == null:
		push_error(
			"The lightning scene root must inherit from Node2D."
		)
		return

	add_child(lightning_instance)

	# Places it in the centre of the TileMap cell.
	lightning_instance.global_position = tilemap.to_global(
		tilemap.map_to_local(cell)
	)

	lightning_instance.rotation_degrees = _get_rotation(direction)

	spawned_lightning.append(lightning_instance)


func _get_rotation(direction: Vector2i) -> float:
	# Assumes the sprite naturally points to the right.
	if direction == Vector2i.RIGHT:
		return 0.0

	if direction == Vector2i.LEFT:
		return 180.0

	if direction == Vector2i.DOWN:
		return 90.0

	if direction == Vector2i.UP:
		return -90.0

	return 0.0


func get_rod_at_cell(
	cell: Vector2i,
	original_rod: Node2D
) -> Node2D:
	for rod_node: Node in get_tree().get_nodes_in_group("ROD"):
		if not rod_node is Node2D:
			continue

		var rod := rod_node as Node2D

		if rod == original_rod:
			continue

		var rod_cell: Vector2i = tilemap.local_to_map(
			tilemap.to_local(rod.global_position)
		)

		if rod_cell == cell:
			return rod

	return null


func is_wall(cell: Vector2i) -> bool:
	var tile_data: TileData = tilemap.get_cell_tile_data(cell)

	if tile_data == null:
		return false

	return tile_data.get_custom_data("blocks_lightning") == true


func _clear_previous_lightning() -> void:
	for lightning_instance: Node2D in spawned_lightning:
		if is_instance_valid(lightning_instance):
			lightning_instance.queue_free()

	spawned_lightning.clear()
