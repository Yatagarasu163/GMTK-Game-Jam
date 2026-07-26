extends Node2D


@export_category("Animated Menu Items")
@export var items: Array[Control]


@export_category("Volume Sliders")
@export var master_slider: HSlider
@export var bgm_slider: HSlider
@export var sfx_slider: HSlider


@export_category("Optional Percentage Labels")
@export var master_value_label: Label
@export var bgm_value_label: Label
@export var sfx_value_label: Label


@onready var transitionBlock: Control = $CanvasLayer/Transition


const SETTINGS_PATH := "user://audio_settings.cfg"
const AUDIO_SECTION := "audio"

const MASTER_BUS := &"Master"
const BGM_BUS := &"BGM"
const SFX_BUS := &"SFX"


var items_y_position: Array[float]
var time_elapsed: float = 0.0


func _ready() -> void:
	_play_opening_animation()

	_setup_slider(
		master_slider,
		_on_master_volume_changed
	)

	_setup_slider(
		bgm_slider,
		_on_bgm_volume_changed
	)

	_setup_slider(
		sfx_slider,
		_on_sfx_volume_changed
	)

	_load_audio_settings()
	_apply_all_volumes()
	_update_all_volume_labels()


func _process(delta: float) -> void:
	time_elapsed += delta

	for i in range(items.size()):
		if items[i] == null:
			continue

		items[i].position.y = (
			items_y_position[i]
			+ sin(time_elapsed * 2.0 + (i * 0.8)) * 3.0
		)


# ---------------------------------------------------------
# Menu animation
# ---------------------------------------------------------

func _play_opening_animation() -> void:
	items_y_position.resize(items.size())

	var transition_tween := create_tween()

	transition_tween.tween_property(
		transitionBlock,
		"position:x",
		-transitionBlock.size.x,
		0.25
	)

	for i in range(items.size()):
		if items[i] == null:
			continue

		var item_x_position: float = items[i].position.x
		items_y_position[i] = items[i].position.y

		if i % 2 == 0:
			items[i].position.x = item_x_position + 1500.0
		else:
			items[i].position.x = item_x_position - 1500.0

		var item_tween := create_tween()

		item_tween.tween_property(
			items[i],
			"position:x",
			item_x_position,
			0.75
		).set_delay(
			i * 0.18
		).set_trans(
			Tween.TRANS_BACK
		).set_ease(
			Tween.EASE_OUT
		)


# ---------------------------------------------------------
# Slider setup
# ---------------------------------------------------------

func _setup_slider(
	slider: HSlider,
	value_changed_callable: Callable
) -> void:
	if slider == null:
		push_warning("An Options menu volume slider is not assigned.")
		return

	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0

	if not slider.value_changed.is_connected(
		value_changed_callable
	):
		slider.value_changed.connect(
			value_changed_callable
		)

	if not slider.drag_ended.is_connected(
		_on_volume_drag_ended
	):
		slider.drag_ended.connect(
			_on_volume_drag_ended
		)


# ---------------------------------------------------------
# Volume slider events
# ---------------------------------------------------------

func _on_master_volume_changed(value: float) -> void:
	_set_bus_volume(MASTER_BUS, value)
	_update_volume_label(master_value_label, value)


func _on_bgm_volume_changed(value: float) -> void:
	_set_bus_volume(BGM_BUS, value)
	_update_volume_label(bgm_value_label, value)


func _on_sfx_volume_changed(value: float) -> void:
	_set_bus_volume(SFX_BUS, value)
	_update_volume_label(sfx_value_label, value)


func _on_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		_save_audio_settings()


# ---------------------------------------------------------
# Audio bus control
# ---------------------------------------------------------

func _set_bus_volume(
	bus_name: StringName,
	slider_value: float
) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		push_warning(
			"Audio bus does not exist: " + String(bus_name)
		)
		return

	var linear_volume: float = clamp(
		slider_value / 100.0,
		0.0,
		1.0
	)

	# Zero volume is treated as muted.
	if linear_volume <= 0.0:
		AudioServer.set_bus_mute(bus_index, true)
		return

	AudioServer.set_bus_mute(bus_index, false)

	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(linear_volume)
	)


func _apply_all_volumes() -> void:
	if master_slider != null:
		_set_bus_volume(
			MASTER_BUS,
			master_slider.value
		)

	if bgm_slider != null:
		_set_bus_volume(
			BGM_BUS,
			bgm_slider.value
		)

	if sfx_slider != null:
		_set_bus_volume(
			SFX_BUS,
			sfx_slider.value
		)


# ---------------------------------------------------------
# Percentage labels
# ---------------------------------------------------------

func _update_all_volume_labels() -> void:
	if master_slider != null:
		_update_volume_label(
			master_value_label,
			master_slider.value
		)

	if bgm_slider != null:
		_update_volume_label(
			bgm_value_label,
			bgm_slider.value
		)

	if sfx_slider != null:
		_update_volume_label(
			sfx_value_label,
			sfx_slider.value
		)


func _update_volume_label(
	label: Label,
	value: float
) -> void:
	if label == null:
		return

	label.text = "%d%%" % int(round(value))


# ---------------------------------------------------------
# Save and load settings
# ---------------------------------------------------------

func _save_audio_settings() -> void:
	var config := ConfigFile.new()

	if master_slider != null:
		config.set_value(
			AUDIO_SECTION,
			"master_volume",
			master_slider.value
		)

	if bgm_slider != null:
		config.set_value(
			AUDIO_SECTION,
			"bgm_volume",
			bgm_slider.value
		)

	if sfx_slider != null:
		config.set_value(
			AUDIO_SECTION,
			"sfx_volume",
			sfx_slider.value
		)

	var save_error: Error = config.save(SETTINGS_PATH)

	if save_error != OK:
		push_warning(
			"Could not save audio settings. Error: "
			+ str(save_error)
		)


func _load_audio_settings() -> void:
	var config := ConfigFile.new()
	var load_error: Error = config.load(SETTINGS_PATH)

	# First time launching the game:
	# use the default volume values.
	if load_error != OK:
		_set_slider_without_signal(master_slider, 100.0)
		_set_slider_without_signal(bgm_slider, 100.0)
		_set_slider_without_signal(sfx_slider, 100.0)
		return

	var master_volume: float = float(
		config.get_value(
			AUDIO_SECTION,
			"master_volume",
			100.0
		)
	)

	var bgm_volume: float = float(
		config.get_value(
			AUDIO_SECTION,
			"bgm_volume",
			100.0
		)
	)

	var sfx_volume: float = float(
		config.get_value(
			AUDIO_SECTION,
			"sfx_volume",
			100.0
		)
	)

	_set_slider_without_signal(
		master_slider,
		master_volume
	)

	_set_slider_without_signal(
		bgm_slider,
		bgm_volume
	)

	_set_slider_without_signal(
		sfx_slider,
		sfx_volume
	)


func _set_slider_without_signal(
	slider: HSlider,
	value: float
) -> void:
	if slider == null:
		return

	slider.set_value_no_signal(value)


# ---------------------------------------------------------
# Back button
# ---------------------------------------------------------

func _on_back_pressed() -> void:
	_save_audio_settings()

	transitionBlock.position.x = 1600.0

	var tween := create_tween()

	tween.tween_property(
		transitionBlock,
		"position:x",
		0.0,
		0.25
	)

	await tween.finished

	get_tree().change_scene_to_file(
		"res://Menus/main_menu.tscn"
	)
