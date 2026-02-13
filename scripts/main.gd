extends Node2D

@export var stamina := 10
@export var lives := 3
@export var score := 0

@export var card_scene: PackedScene
@export var all_card_data: Array[CardData]

@onready var grid = $GridContainer
@onready var draw_pile = $DrawPile

func _ready():
	shuffle_and_deal()

func deduct_stamina(amt):
	if stamina - amt > 0:
		stamina -= amt
	else:
		lose_a_life()

func lose_a_life():
	if lives - 1 > 0:
		lives -= 1
		stamina = 10
	else:
		pass # Game over, add gameover func later 

func shuffle_and_deal():
	for child in grid.get_children():
		child.queue_free()
	for child in draw_pile.get_children():
		child.queue_free()

	var deck = all_card_data.duplicate()
	deck.shuffle()

	var grid_cards = deck.slice(0, 21)

	var pile_cards = deck.slice(21, deck.size())

	deal_grid(grid_cards)
	deal_pile(pile_cards)

func deal_grid(cards):
	var rows = 3
	var cols = 7
	var spacing = Vector2(160, 160)

	for i in range(cards.size()):
		var row = i / cols
		var col = i % cols

		var card = card_scene.instantiate()
		card.card_data = cards[i]
		card.is_reversible = true

		card.position = Vector2(
			col * spacing.x,
			row * spacing.y
		)

		grid.add_child(card)

func deal_pile(cards):
	var offset = Vector2(0, 0)

	for i in range(cards.size()):
		var card = card_scene.instantiate()
		card.card_data = cards[i]
		card.is_reversible = true

		card.position = offset * i
		draw_pile.add_child(card)
		
		card.set_face_down()

func _on_shuffle_pressed() -> void:	
	shuffle_and_deal()



func _on_board_player_room_changed(room: String) -> void:
	$UIElements/CurrentRoomLabel.text = room
