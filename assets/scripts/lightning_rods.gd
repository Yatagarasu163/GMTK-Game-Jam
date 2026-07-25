extends Node2D

@export var rod_name: String;

#To do shit:
#1) Detect lightning rods /
#2) Detect walls 
#3) Detect Players
#4) Sort positions of the arrays / 
#5) Check if walls come first or if lightning rods come first
#6) If lightning rod comes first, zap only the first lightning rod, then check if player in between the two lightning rods

var right_array: Array[Node2D] = [];
var down_array: Array[Node2D] = [];

@export var tilemap: TileMapLayer
@export var lightning: PackedScene

func _ready() -> void:
	lightning = preload("res://assets/prefabs/lightning_strike.tscn");
	print(rod_name, tilemap.local_to_map(global_position));

func _on_right_area_entered(area: Area2D) -> void:
	var object = area.get_parent();
	if object.is_in_group("WALL") || object.is_in_group("PLAYER") || object.is_in_group("ROD"):
		if object.global_position != global_position && !right_array.has(object) && area.name == "Hitbox":
			right_array.append(object);

func _on_down_area_entered(area: Area2D) -> void:
	var object = area.get_parent();
	if object.is_in_group("WALL") || object.is_in_group("PLAYER") || object.is_in_group("ROD"):
		if object.global_position != global_position && !down_array.has(object) && area.name == "Hitbox":
			down_array.append(object);

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		resolve_lightning(); 

func resolve_lightning() -> void:
	
	# Sorting array for positions
	right_array.sort_custom(sort_right);
	print(rod_name, " Right Array: ", right_array);
	cast_lightning(right_array, Vector2.RIGHT);
	
	down_array.sort_custom(sort_down);
	print(rod_name, " Down Array: ", down_array);
	
	print("\n");


func cast_lightning(direction_array: Array[Node2D], direction_vector: Vector2) -> void:
	var target_array:Array[Node2D] = direction_array;
	var target_position: Vector2i;
	for item in target_array:
		if item.is_in_group("WALL"):
			break;
		if item.is_in_group("ROD"):
			target_position = tilemap.local_to_map(tilemap.to_local(item.global_position));
			print("Target position: ", target_position);
			break;
			
	if direction_vector == Vector2.RIGHT || direction_vector == Vector2.LEFT:
		var current_x_pos: int = tilemap.local_to_map(tilemap.to_local(global_position)).x + direction_vector.x;
		#var current_pos: Vector2i = tilemap.local_to_map(global_position + (direction_vector));
		
		while current_x_pos != target_position.x:
			print("Current position: ", current_x_pos);
			var lightning_visual:Node2D = lightning.instantiate();
			get_parent().add_child(lightning_visual);
			#lightning_visual.global_position = tilemap.map_to_local(tilemap.to_global(lightning_visual.global_position + direction_vector))
			lightning_visual.global_position = tilemap.map_to_local(tilemap.to_global(Vector2i(current_x_pos, target_position.y)));
			
			print(tilemap.local_to_map(lightning_visual.global_position));
			current_x_pos += (1 * direction_vector.x);
	elif direction_vector == Vector2.UP || direction_vector == Vector2.DOWN:
		var current_y_pos : int = tilemap.local_to_map(tilemap.to_local(global_position)).y + direction_vector.y;
		
		while current_y_pos != target_position.y:
			var lightning_visual:Node2D = lightning.instantiate();
			get_parent().add_child(lightning_visual);
			lightning_visual.global_position = tilemap.map_to_local(tilemap.to_global(Vector2i(target_position.x, current_y_pos)));
			
			print(tilemap.local_to_map(lightning_visual.global_position));
			current_y_pos += (1 * direction_vector.y);

func sort_right(a, b) -> bool:
	return a.global_position.x < b.global_position.x;
	
func sort_left(a, b) -> bool:
	return a.global_position.x > b.global_position.x;
	
func sort_up(a, b) -> bool: 
	return a.global_position.y > b.global_position.y;
	
func sort_down(a, b) -> bool:
	return a.global_position.y < b.global_position.y;
	
