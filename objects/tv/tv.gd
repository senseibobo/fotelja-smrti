class_name TV
extends Node3D


const channels: Array[VideoStreamTheora] = [
	preload("res://objects/tv/channels/0.0-90.0.ogv"),
	preload("res://objects/tv/channels/10.0-100.0.ogv"),
	preload("res://objects/tv/channels/152.0-245.0.ogv"),
	preload("res://objects/tv/channels/1917.0-2172.0.ogv"),
	preload("res://objects/tv/channels/Džudžubana viski - Nikad izvini.ogv"),
	preload("res://objects/tv/channels/gen z meme compilation.ogv"),
	preload("res://objects/tv/channels/Juno Kilometar - svraka (Official video).ogv"),
	preload("res://objects/tv/channels/Tralalero tralala VS Lirili Larila.ogv"),
	preload("res://objects/tv/channels/When youre overqualified for the job.ogv")
]

@export var stream_player: VideoStreamPlayer
@export var player: Player

var current_channel: int = 5

var on: bool = false
var reverb_effect: AudioEffectReverb

func _ready():
	reverb_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index(&"TV"),0)
	turn_off()


func _process(delta):
	if player:
		stream_player.volume_db = -player.global_position.distance_to(global_position)/3.0
		reverb_effect.wet = (1.0-player.sanity)/2.0


func next_channel():
	set_channel((current_channel+1) % channels.size())


func previous_channel():
	set_channel(fposmod(current_channel-1, channels.size()))


func turn_on():
	if not on:
		set_channel(current_channel)


func turn_off():
	on = false
	stream_player.stop()


func set_channel(new_channel: int):
	on = true
	current_channel = new_channel
	stream_player.stream = channels[current_channel]
	stream_player.play()
	stream_player.stream_position = randf()*stream_player.get_stream_length()
	
