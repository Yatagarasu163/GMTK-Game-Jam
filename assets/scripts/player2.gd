extends CharacterBody2D


@onready var ray_cast = $RayCast2D
@onready var sprite = $Sprite2D # Visual node
@export var moves_left = 10
@export var rods_left = 4
@export var lives_left = 3
@export var Spawn_object: PackedScene
var input_dir
const tile_size = 128
var moving = false
var previous_position : Vector2
var facing = Vector2i.DOWN

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("P2 PLACE"):
		if not ray_cast.is_colliding() and rods_left > 0:
			rods_left -= 1
			place_object()

func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement
	# Checks on button press, hold functionality can also be added but tile based bombs calls for a bit more precision
	input_dir = Vector2.ZERO
	if Input.is_action_just_pressed("P2 UP"):
		facing = Vector2i.UP
		input_dir = Vector2(0,-1)
		collide_check()
	elif Input.is_action_just_pressed("P2 DOWN"):
		facing = Vector2i.DOWN
		input_dir = Vector2(0,1)
		collide_check()
	elif Input.is_action_just_pressed("P2 LEFT"):
		facing = Vector2i.LEFT
		input_dir = Vector2(-1,0)
		collide_check()
	elif Input.is_action_just_pressed("P2 RIGHT"):
		facing = Vector2i.RIGHT
		input_dir = Vector2(1,0)
		collide_check()
		
func collide_check():
	if input_dir != Vector2.ZERO:
		# Point the raycast in the direction of the input
		ray_cast.target_position = input_dir * tile_size
		ray_cast.force_raycast_update()
		
		# If the raycast DOES NOT hit a wall, move!
		if not ray_cast.is_colliding():
			move()

func move():
	#moves character in direction that was pressed
	if input_dir:
		if moving == false and moves_left > 0:
			moves_left -=1
			moving = true
			var tween = create_tween()
			tween.tween_property(self, "position", position + input_dir * tile_size, 0)
			tween.tween_callback(move_false)
			
func move_false():
	moving = false
	
func place_object() -> void:
	if Spawn_object:
		var new_object = Spawn_object.instantiate()
		new_object.global_position = global_position + Vector2(facing) * tile_size
		
		get_parent().add_child(new_object)
