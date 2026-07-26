extends TextureRect


@export var items: Array[Control]
@export var transition_block: Control
@export var main_menu_scene: PackedScene


var original_positions: Array[Vector2]
var time_elapsed: float = 0.0
var menu_open: bool = false


func _ready() -> void:
	# Allows this menu to work while the match is paused.
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hide()


func _process(delta: float) -> void:
	if not menu_open:
		return

	time_elapsed += delta

	for i in range(items.size()):
		items[i].position.y = (
			original_positions[i].y
			+ sin(time_elapsed * 2.0 + i * 0.8) * 3.0
		)


func _play_entrance_animation() -> void:
	original_positions.resize(items.size())

	# Move the transition away from the screen.
	var transition_tween := create_tween()
	transition_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	transition_tween.tween_property(
		transition_block,
		"position:x",
		-transition_block.size.x,
		0.25
	)

	# Slide the label and buttons in from alternating sides.
	for i in range(items.size()):
		original_positions[i] = items[i].position

		if i % 2 == 0:
			items[i].position.x += 1500.0
		else:
			items[i].position.x -= 1500.0

		var item_tween := create_tween()
		item_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

		item_tween.tween_property(
			items[i],
			"position:x",
			original_positions[i].x,
			0.75
		).set_delay(
			i * 0.18
		).set_trans(
			Tween.TRANS_BACK
		).set_ease(
			Tween.EASE_OUT
		)


func _play_exit_transition() -> void:
	transition_block.position.x = get_viewport_rect().size.x

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.tween_property(
		transition_block,
		"position:x",
		0.0,
		0.25
	)

	await tween.finished


func _on_restart_pressed() -> void:
	await _play_exit_transition()

	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	await _play_exit_transition()

	get_tree().paused = false
	get_tree().change_scene_to_file(
		"res://Menus/main_menu.tscn"
	)


func _on_restart_button_pressed() -> void:
	pass # Replace with function body.


func _on_main_menu_button_pressed() -> void:
	pass # Replace with function body.
