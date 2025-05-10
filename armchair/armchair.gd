class_name Armchair
extends Node3D



func _on_interactable_interacted(player: Player) -> void:
	player.sit(self)
	
