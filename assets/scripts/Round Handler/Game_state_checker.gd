extends Node


signal game_ended(result_text: String, winner_player: int)
signal game_continues


@export_category("Player Health")

# Drag the health component for each player here when it exists.
@export var player_1_health_source: Node
@export var player_2_health_source: Node

# Change this only if the health script uses another variable name.
@export var health_property_name: StringName = &"current_health"


@export_category("Game References")

@export var round_manager: Node

# The entire game-over menu.
@export var game_over_menu: Control

# The label that will display "Player 1 Wins", etc.
@export var result_label: Label


@export_category("Settings")

@export var freeze_game_on_end: bool = true
@export var show_debug_messages: bool = true

@export var player_1_anim: AnimatedSprite2D; 
@export var player_2_anim: AnimatedSprite2D; 


var game_over: bool = false


func _ready() -> void:
	
	player_1_anim.visible = false;
	player_2_anim.visible = false;
	
	# Hide the menu when the match begins.
	if game_over_menu != null:
		game_over_menu.hide()

		# Allows the menu and its buttons to work while the game is paused. 
		game_over_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED


# Call this after lightning has finished applying damage to both players.
func check_game_state(
	player_1_health_override: Variant = null,
	player_2_health_override: Variant = null
) -> bool:
	if game_over:
		return true

	var player_1_health: Variant = player_1_health_override
	var player_2_health: Variant = player_2_health_override

	# Use the actual health components when no test values were supplied.
	if player_1_health == null:
		player_1_health = _read_health(player_1_health_source)

	if player_2_health == null:
		player_2_health = _read_health(player_2_health_source)

	if player_1_health == null or player_2_health == null:
		push_warning(
			"Game state could not be checked because a player's health is unavailable."
		)
		return false

	if show_debug_messages:
		print(
			"Checking game state — Player 1: ",
			player_1_health,
			", Player 2: ",
			player_2_health
		)

	var player_1_dead: bool = player_1_health <= 0
	var player_2_dead: bool = player_2_health <= 0

	if player_1_dead and player_2_dead:
		end_game("Draw!", 0)
		player_1_anim.play("player_die");
		player_2_anim.play("player_die");
		return true

	if player_1_dead:
		end_game("Player 2 Wins!", 2)
		player_1_anim.play("player_die");
		player_2_anim.play("player_live");
		return true

	if player_2_dead:
		end_game("Player 1 Wins!", 1)
		player_1_anim.play("player_live");
		player_2_anim.play("player_die");
		return true

	game_continues.emit()

	if show_debug_messages:
		print("Both players are alive. Match continues.")

	return false


func end_game(result_text: String, winner_player: int) -> void:
	if game_over:
		return

	game_over = true
	
	player_1_anim.visible = true;
	player_2_anim.visible = true;
	
	# Stop the countdown and prevent the next round from starting.
	if round_manager != null and round_manager.has_method("end_match"):
		round_manager.end_match()

	if result_label != null:
		result_label.text = result_text

	if game_over_menu != null:
		game_over_menu.show()

	game_ended.emit(result_text, winner_player)

	if show_debug_messages:
		print("GAME OVER: ", result_text)

	# Pause after showing the menu.
	if freeze_game_on_end:
		get_tree().paused = true


func reset_game_state() -> void:
	get_tree().paused = false
	game_over = false

	if game_over_menu != null:
		game_over_menu.hide()


func _read_health(health_source: Node) -> Variant:
	if health_source == null:
		return null

	if not _node_has_property(health_source, health_property_name):
		push_warning(
			str(
				health_source.name,
				" does not contain the property: ",
				health_property_name
			)
		)
		return null

	return health_source.get(health_property_name)


func _node_has_property(node: Node, property_name: StringName) -> bool:
	for property_data: Dictionary in node.get_property_list():
		if property_data["name"] == property_name:
			return true

	return false
