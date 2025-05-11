class_name Bar
extends Control


@export var node: Node
@export var property: StringName
@export var color: Color


func _ready():
	$ColorRect.anchor_right = 0.0
	$ColorRect.color = color


func _process(delta):
	if node and property:
		$ColorRect.anchor_right = node.get(property)
