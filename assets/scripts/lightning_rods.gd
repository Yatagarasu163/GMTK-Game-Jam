extends Node2D


@export_category("Lightning Setup")

# Drag the LightningManager node into this field in the Inspector.
@export var lightning_manager: Node

# Temporary testing option.
@export var allow_keyboard_testing: bool = true
@export var test_input_action: StringName = &"jump"


func _ready() -> void:
	# Allows the Lightning Manager to detect this rod.
	if not is_in_group("ROD"):
		add_to_group("ROD")

	if lightning_manager == null:
		push_warning(
			"Lightning rod has no Lightning Manager assigned."
		)


func _process(_delta: float) -> void:
	if not allow_keyboard_testing:
		return

	if Input.is_action_just_pressed(test_input_action):
		activate_lightning()


func activate_lightning() -> void:
	if lightning_manager == null:
		push_error(
			"Cannot activate lightning: Lightning Manager is not assigned."
		)
		return

	if not lightning_manager.has_method("cast_lightning"):
		push_error(
			"The assigned Lightning Manager does not contain cast_lightning()."
		)
		return

	lightning_manager.cast_lightning(self)
