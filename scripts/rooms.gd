extends Area2D

@export var room_id: String
@export var required_item: String
var is_complete: bool
var player_inside: bool

signal player_entered

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_inside = true
		emit_signal("player_entered", room_id)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_inside = false
