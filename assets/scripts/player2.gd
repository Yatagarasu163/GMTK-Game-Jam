extends CharacterBody2D


@onready var ray_cast = $RayCast2D
@export var max_moves_left = 10
var moves_left = max_moves_left;
@export var max_rods_left = 2;
var rods_left = max_rods_left;
@export var lives_left = 3
@export var Spawn_object: PackedScene
var input_dir
@export var tile_size = 64
var moving = false
var previous_position : Vector2
var facing = Vector2i.DOWN
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D;
var current_anim: String = "Idle_Front";
var is_hit_anim: bool = false;

func _ready() -> void:
	is_hit_anim = false;
	var round_manager = get_tree().get_first_node_in_group("round_manager");
	anim.play(current_anim);
	
	if round_manager:
		round_manager.round_started.connect(_on_round_start);
		round_manager.round_ended.connect(_on_round_end);
	

func _on_round_start(_round_count: int) -> void:
	moves_left = max_moves_left;
	rods_left = max_rods_left;
	moving = false;

	
func _on_round_end(_round_count: int) -> void: 
	moving = true;
	moves_left = 0;
	rods_left = 0;

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("P2 PLACE"):
		if not ray_cast.is_colliding() and rods_left > 0:
			rods_left -= 1
			place_object()

func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement
	# Checks on button press, hold functionality can also be added but tile based bombs calls for a bit more precision
	input_dir = Vector2.ZERO
	if !is_hit_anim: 
		if Input.is_action_just_pressed("P2 UP"):
			facing = Vector2i.UP
			input_dir = Vector2(0,-1)
			if current_anim != "Idle_Back": 
				current_anim = "Idle_Back";
				anim.play(current_anim);
			collide_check()
		elif Input.is_action_just_pressed("P2 DOWN"):
			facing = Vector2i.DOWN
			input_dir = Vector2(0,1)
			
			if current_anim != "Idle_Front": 
				current_anim = "Idle_Front";
				anim.play(current_anim);
			
			collide_check()
		elif Input.is_action_just_pressed("P2 LEFT"):
			facing = Vector2i.LEFT
			input_dir = Vector2(-1,0)
			anim.scale.x = -4;
			current_anim = "Idle_Side";
			anim.play(current_anim);
			
			collide_check()
		elif Input.is_action_just_pressed("P2 RIGHT"):
			facing = Vector2i.RIGHT
			input_dir = Vector2(1,0)
			anim.scale.x = 4;
			current_anim = "Idle_Side";
			anim.play(current_anim);
			collide_check()
		
func collide_check():
	if input_dir != Vector2.ZERO:
		# Point the raycast in the direction of the input
		ray_cast.target_position = input_dir * tile_size * 2
		ray_cast.force_raycast_update()
		print(ray_cast.target_position);
		
		if ray_cast.is_colliding():
			print("Is raycast hitting: ", ray_cast.is_colliding());
			print("I hit: ", ray_cast.get_collider());
			var collider = ray_cast.get_collider();
			
			if collider.is_in_group("ROD") || collider.is_in_group("WALL"):
				return;
		
		# If the raycast DOES NOT hit a wall, move!
		if not ray_cast.is_colliding():
			move()

func move():
	#moves character in direction that was pressed
	if input_dir:
		if moving == false && moves_left > 0:
			moves_left -=1
			moving = true
			var tween = create_tween()
			tween.tween_property(self, "position", position + input_dir * tile_size, 0)
			tween.tween_callback(move_false)
			
func move_false():
	moving = false
	
func place_object() -> void:
	if Spawn_object:
		if current_anim != "Place_Rod":
			current_anim = "Place_Rod";
			anim.play(current_anim);
			await anim.animation_finished;
		var new_object = Spawn_object.instantiate()
		new_object.global_position = global_position + Vector2(facing) * tile_size
		current_anim = "Idle_Front";
		anim.play(current_anim);
		
		get_parent().add_child(new_object)
		
	if Input.is_action_just_pressed("P1 UP"):
		facing = Vector2i.UP
		input_dir = Vector2(0,-1)
		if current_anim != "Idle_Back": 
			current_anim = "Idle_Back";
			anim.play(current_anim);
		collide_check()
	elif Input.is_action_just_pressed("P1 DOWN"):
		facing = Vector2i.DOWN
		input_dir = Vector2(0,1)
		if current_anim != "Idle_Front": 
			current_anim = "Idle_Front";
			anim.play(current_anim);
		collide_check()
	elif Input.is_action_just_pressed("P1 LEFT"):
		facing = Vector2i.LEFT
		input_dir = Vector2(-1,0)
		anim.scale.x = -4;
		current_anim = "Idle_Side";
		anim.play(current_anim);
		collide_check()
	elif Input.is_action_just_pressed("P1 RIGHT"):
		facing = Vector2i.RIGHT
		input_dir = Vector2(1,0)
		anim.scale.x = 4;
		current_anim = "Idle_Side";
		anim.play(current_anim);
		collide_check()
		
func is_hit() -> void:
	is_hit_anim = true;
	current_anim = "Hit";
	anim.play(current_anim);
	await anim.animation_finished;
	is_hit_anim = false;
	current_anim = "Idle_Front";
	anim.play(current_anim);

func is_die() -> void:
	is_hit_anim = true;
	moving = true;
	current_anim = "Die";
	anim.play(current_anim);
	await anim.animation_finished;
