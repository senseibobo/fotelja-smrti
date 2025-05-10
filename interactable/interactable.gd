class_name Interactable
extends Node3D

signal interacted(player: Player)

func on_interact(player: Player):
	interacted.emit(player)
