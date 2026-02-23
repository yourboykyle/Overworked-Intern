extends Area2D

@export var room_id: String
@export var required_item: String
var is_complete: bool
var player_inside: bool

signal player_entered(room_id : String)
signal player_left()
signal room_completed(room_id : String)

func complete_room():
	is_complete = true
	room_completed.emit(room_id)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_inside = true
		player_entered.emit(room_id)
		
#		print("Player inside: " + str(player_inside))
#		print("Room ID: " + room_id)
#		print("Required item: " + required_item)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_inside = false
		player_left.emit()
