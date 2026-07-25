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
var left_array: Array[Node2D] = [];
var up_array: Array[Node2D] = [];
var down_array: Array[Node2D] = [];

@export var tilemap: TileMapLayer;
@export var lightning: PackedScene;

func _ready() -> void:
	lightning = preload("res://assets/prefabs/lightning_strike.tscn");
	print(rod_name, tilemap.local_to_map(global_position));

func _on_right_area_entered(area: Area2D) -> void:
	var object = area.get_parent();
	if object.is_in_group("WALL") || object.is_in_group("PLAYER") || object.is_in_group("ROD"):
		if object.global_position != global_position && !right_array.has(object) && area.name == "Hitbox":
			right_array.append(object);

func _on_up_area_entered(area: Area2D) -> void:
	var object = area.get_parent();
	if object.is_in_group("WALL") || object.is_in_group("PLAYER") || object.is_in_group("ROD"):
		if object.global_position != global_position && !up_array.has(object) && area.name == "Hitbox":
			up_array.append(object);
		
		

func _on_down_area_entered(area: Area2D) -> void:
	var object = area.get_parent();
	if object.is_in_group("WALL") || object.is_in_group("PLAYER") || object.is_in_group("ROD"):
		if object.global_position != global_position && !down_array.has(object) && area.name == "Hitbox":
			down_array.append(object);

func _on_left_area_entered(area: Area2D) -> void:
	var object = area.get_parent();
	if object.is_in_group("WALL") || object.is_in_group("PLAYER") || object.is_in_group("ROD"):
		if object.global_position != global_position && !left_array.has(object) && area.name == "Hitbox":
			left_array.append(object);

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		resolve_lightning(); 

func resolve_lightning() -> void:
	
	# Sorting array for positions
	right_array.sort_custom(sort_right);
	print(rod_name, " Right Array: ", right_array);
	
	left_array.sort_custom(sort_left);
	print(rod_name, " Left Array: ", left_array);
	
	up_array.sort_custom(sort_up);
	print(rod_name, " Up Array: ", up_array);
	
	down_array.sort_custom(sort_down);
	print(rod_name, " Down Array: ", down_array);
	
	print("\n");
	
	var target_position_right: Vector2i;
	
	for item in right_array:
		if item.is_in_group("ROD"):
			target_position_right = tilemap.local_to_map(item.global_position);
			print(target_position_right)
			break;
	
	var current_x_pos: int = tilemap.local_to_map(global_position).x + 1;
	while current_x_pos < target_position_right.x: 
		var eh = lightning.instantiate();
		eh.global_position = tilemap.map_to_local(Vector2i(current_x_pos, tilemap.local_to_map(global_position).y));
		print(eh.global_position);
		print(tilemap.local_to_map(eh.global_position));
		current_x_pos += 1;
	
func sort_right(a, b) -> bool:
	return a.global_position.x < b.global_position.x;
	
func sort_left(a, b) -> bool:
	return a.global_position.x > b.global_position.x;
	
func sort_up(a, b) -> bool: 
	return a.global_position.y > b.global_position.y;
	
func sort_down(a, b) -> bool:
	return a.global_position.y < b.global_position.y;
	
