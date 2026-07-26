extends Node2D

@export var rod_name: String
@export var tilemap: TileMapLayer
@export var lightning: PackedScene

@onready var MyHit := $Hitbox
@onready var CheckHit := $"Check Hitbox"

var lightning_bolts: Array[Node2D]
var keep_going: bool
var hit: bool

func _ready() -> void:
	lightning = preload("res://assets/prefabs/lightning_strike.tscn");
	
	var manager = get_tree().get_first_node_in_group("round_manager");
	
	if manager:
		manager.lightning_triggered.connect(Go_Check);
		manager.round_started.connect(_clear_rods);

func _clear_rods(round_timer: int):
	#clearing all previous bolts
	for bolt in lightning_bolts:
		bolt.queue_free()
	lightning_bolts.clear()

func Go_Check():
	var count = 0;
	#checking horizontal tiles
	keep_going = true
	CheckHit.position = Vector2.ZERO
	while keep_going:
		CheckHit.global_position.x += 64
		await get_tree().physics_frame
		count += 1;
	while hit:
		CheckHit.global_position.x -= 64
		await get_tree().physics_frame
		if CheckHit.position != Vector2.ZERO && count > 1:
			spawnLightning(true)
			count -= 1
	#checking vertical tiles
	count = 0
	keep_going = true
	CheckHit.position = Vector2.ZERO
	while keep_going:
		CheckHit.global_position.y += 64
		await get_tree().physics_frame
		count += 1
	while hit:
		CheckHit.global_position.y -= 64
		await get_tree().physics_frame
		if CheckHit.position != Vector2.ZERO && count > 1:
			spawnLightning(false)
			count -= 1
	pass

func spawnLightning(is_horizontal: bool):
	print(CheckHit.position)
	var current_lightning:Node2D = lightning.instantiate()
	if !is_horizontal:
		current_lightning.rotation_degrees = 90.0;
	current_lightning.position = CheckHit.position
	lightning_bolts.append(current_lightning)
	add_child(current_lightning)

#is_in_group("WALL")
#is_in_group("PLAYER")
#is_in_group("ROD"):

func _on_check_hitbox_area_entered(area: Area2D) -> void:
	print(area.name)
	if area != MyHit:
		if area.is_in_group("ROD"):
			print("Found rod")
			keep_going = false
			hit = true
	else:
		hit = false


func _on_check_hitbox_body_entered(body: Node2D) -> void:
	print(body.name)
	if body != MyHit:
		if body.is_in_group("WALL"):
			print("Found wall")
			keep_going = false
			hit = false
	else:
		hit = false
