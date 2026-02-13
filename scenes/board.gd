extends Node2D

@onready var player_current_room: String

func _ready():
	for room in $Rooms.get_children():
		room.player_entered.connect(_on_player_entered_room)
		room.player_left.connect(_on_player_left_room)

func _on_player_entered_room(room_id: String):
	player_current_room = room_id
	print(player_current_room)

func _on_player_left_room():
	player_current_room = "Hallway"
	print(player_current_room)
