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

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		Go_Check()

func Go_Check():
	#checking horizontal tiles
	keep_going = true
	CheckHit.position = Vector2.ZERO
	while keep_going:
		CheckHit.global_position.x += 64
		await get_tree().physics_frame
	while hit:
		CheckHit.global_position.x -= 64
		await get_tree().physics_frame
		if CheckHit.position != Vector2.ZERO:
			spawnLightning()
	#checking vertical tiles
	keep_going = true
	CheckHit.position = Vector2.ZERO
	while keep_going:
		CheckHit.global_position.y += 64
		await get_tree().physics_frame
	while hit:
		CheckHit.global_position.y -= 64
		await get_tree().physics_frame
		if CheckHit.position != Vector2.ZERO:
			spawnLightning()
	pass

func spawnLightning():
	print(CheckHit.position)
	var current_lightning:Node2D = lightning.instantiate()
	current_lightning.position = CheckHit.position
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
