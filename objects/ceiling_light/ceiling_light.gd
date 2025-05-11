class_name CeilingLight
extends Node3D


@export var player: Player
@export var light: OmniLight3D


func _process(delta):
	if player:
		light.light_energy = player.sanity
