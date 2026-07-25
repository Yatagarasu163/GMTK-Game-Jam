extends Node2D

@export var tilemap: TileMapLayer;

func cast_lightning(rod):
	var start_cell = tilemap.local_to_map(tilemap.to_local(rod.global_position));
	
	check_direction(start_cell, Vector2i.RIGHT);
	check_direction(start_cell, Vector2i.LEFT);
	check_direction(start_cell, Vector2i.UP);
	check_direction(start_cell, Vector2i.DOWN);
	
func check_direction(start_cell, direction):
	
	var current_cell = start_cell;
	
	while true:
		
		current_cell += direction
		
		print("Checking:", current_cell);
		
		if is_wall(current_cell):
			print("Lightning stopped");
			break;
			
func is_wall(cell):
	
	var tile = tilemap.get_cell_tile_data(cell)
	
	if tile == null:
		return false;
	
	return tile.get_custom_data("blocks_lightning");
