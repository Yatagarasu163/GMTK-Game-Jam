extends Node2D

@onready var bgm: AudioStreamPlayer2D = $bgm;

var music_library = {
	"bgm": preload("res://assets/Audio/Music/Type shi-.mp3")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_music("bgm");


func play_music(music_name: String) -> void:
	if not music_library.has(music_name):
		return;
	
	if bgm.stream == music_library[music_name]:
		return;
	
	bgm.stream = music_library[music_name];
	bgm.volume_db = -2.0;
	bgm.play();
