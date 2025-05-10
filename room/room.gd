class_name Room
extends Node3D


@export var player: Player
@export var armchair: Armchair
@export var tv: TV


func _ready():
	player.sit(armchair)
