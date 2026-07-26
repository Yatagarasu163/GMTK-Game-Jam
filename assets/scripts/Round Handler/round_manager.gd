extends Node


# Other systems can connect to these signals.
signal round_started(round_number: int)
signal time_updated(seconds_left: int)
signal lightning_triggered
signal round_ended(round_number: int)
signal match_ended


# Editable from the Godot Inspector.
@export_range(0.1, 120.0, 0.1) var round_duration: float = 5.0
@export_range(0.0, 10.0, 0.1) var next_round_delay: float = 1.0

# Tick this in the Inspector only while testing.
@export var auto_start_for_testing: bool = false
@export var show_debug_messages: bool = true


# Public match information.
var current_round: int = 0
var round_active: bool = false
var match_active: bool = false


@onready var round_timer: Timer = $RoundTimer
@onready var next_round_timer: Timer = $NextRoundDelay


var _last_displayed_second: int = -1


func _ready() -> void:
	# Each timer should stop after firing once.
	round_timer.one_shot = true
	next_round_timer.one_shot = true

	# Connect the timer signals through code.
	round_timer.timeout.connect(_on_round_timer_timeout)
	next_round_timer.timeout.connect(_on_next_round_delay_timeout)

	if auto_start_for_testing:
		start_match()


func _process(_delta: float) -> void:
	if not match_active or not round_active:
		return

	# The internal timer uses decimals, but the UI receives whole seconds.
	var seconds_left: int = int(ceil(round_timer.time_left))

	if seconds_left < 0:
		seconds_left = 0

	if seconds_left != _last_displayed_second:
		_last_displayed_second = seconds_left
		time_updated.emit(seconds_left)

		if show_debug_messages:
			print("Time left: ", seconds_left)


func start_match() -> void:
	if match_active:
		return

	current_round = 0
	match_active = true

	round_timer.paused = false
	next_round_timer.paused = false

	if show_debug_messages:
		print("Match started")

	start_round()


func start_round() -> void:
	if not match_active:
		return

	current_round += 1
	round_active = true

	_last_displayed_second = int(ceil(round_duration))

	round_timer.start(round_duration)

	round_started.emit(current_round)
	time_updated.emit(_last_displayed_second)

	if show_debug_messages:
		print("Round ", current_round, " started")
		print("Time left: ", _last_displayed_second)


func _on_round_timer_timeout() -> void:
	if not match_active:
		return

	round_active = false
	_last_displayed_second = 0

	# The displayed timer reaches zero first.
	time_updated.emit(0)

	# Lightning activates exactly at zero.
	lightning_triggered.emit()

	# The current round is now finished.
	round_ended.emit(current_round)

	if show_debug_messages:
		print("Time left: 0")
		print("LIGHTNING!")
		print("Round ", current_round, " ended")

	# A lightning or health system may call end_match() while handling
	# lightning_triggered, so check again before preparing another round.
	if not match_active:
		return

	if next_round_delay <= 0.0:
		start_round()
	else:
		next_round_timer.start(next_round_delay)


func _on_next_round_delay_timeout() -> void:
	if match_active:
		start_round()


# The health system can call this when a player's health reaches zero.
func end_match() -> void:
	if not match_active:
		return

	match_active = false
	round_active = false

	round_timer.stop()
	next_round_timer.stop()

	match_ended.emit()

	if show_debug_messages:
		print("Match ended")


# These can be connected to a pause system later.
func pause_round_system() -> void:
	round_timer.paused = true
	next_round_timer.paused = true

	if show_debug_messages:
		print("Round system paused")


func resume_round_system() -> void:
	if not match_active:
		return

	round_timer.paused = false
	next_round_timer.paused = false

	if show_debug_messages:
		print("Round system resumed")


func reset_match() -> void:
	match_active = false
	round_active = false
	current_round = 0
	_last_displayed_second = -1

	round_timer.stop()
	next_round_timer.stop()

	round_timer.paused = false
	next_round_timer.paused = false

	time_updated.emit(0)

	if show_debug_messages:
		print("Match reset")
