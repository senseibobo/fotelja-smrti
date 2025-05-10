class_name TV
extends Node3D


const channels: Array[VideoStreamTheora] = [
	preload("res://tv/channels/152.0-245.0.ogv"),
	preload("res://tv/channels/1917.0-2172.0.ogv"),
	preload("res://tv/channels/Alo, predsedniče... - Nikad izvini.ogv"),
	preload("res://tv/channels/Džudžubana viski - Nikad izvini.ogv"),
	preload("res://tv/channels/gen z meme compilation.ogv"),
	preload("res://tv/channels/Tralalero tralala VS Lirili Larila.ogv"),
]

@export var stream_player: VideoStreamPlayer

var current_channel: int

func _ready():
	turn_off()


func next_channel():
	set_channel((current_channel+1) % channels.size())


func previous_channel():
	set_channel(fposmod(current_channel-1, channels.size()))


func turn_on():
	stream_player.play()


func turn_off():
	stream_player.stop()


func set_channel(new_channel: int):
	current_channel = new_channel
	stream_player.stream = channels[current_channel]
	stream_player.play()
	stream_player.stream_position = randf()*stream_player.get_stream_length()
	
