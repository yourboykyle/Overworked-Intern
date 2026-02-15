extends Node2D

@export var stamina := 10
@export var lives := 3
@export var score := 0

@export var card_scene: PackedScene
@export var all_card_data: Array[CardData]

@onready var grid = $GridContainer
@onready var draw_pile = $DrawPile
@onready var draw_pile_label = $UIElements/DrawPileCount

var flipped_cards: Array = []
var checking_match := false

@onready var match_slots = $MatchedPile

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
		card.connect("card_flipped", _on_card_flipped)
		card.add_to_group("memory_cards")

		card.position = Vector2(
			col * spacing.x,
			row * spacing.y
		)

		card.grid_index = i
		grid.add_child(card)
		card.set_face_down()

func deal_pile(cards):
	var offset = Vector2(0, 0)

	for i in range(cards.size()):
		var card = card_scene.instantiate()
		card.card_data = cards[i]
		card.is_reversible = true
		card.connect("card_flipped", _on_card_flipped)
		card.add_to_group("memory_cards")

		card.position = offset * i
		draw_pile.add_child(card)
		
		card.set_face_down()
	
	update_draw_pile_label()

func _on_shuffle_pressed() -> void:	
	shuffle_and_deal()



func _on_board_player_room_changed(room: String) -> void:
	$UIElements/CurrentRoomLabel.text = room

func _on_card_flipped(card):
	if checking_match:
		return

	if not card.is_face_up:
		return

	flipped_cards.append(card)

	if flipped_cards.size() == 2:
		checking_match = true
		lock_all_cards()
		check_match()

func check_match():
	var card1 = flipped_cards[0]
	var card2 = flipped_cards[1]

	if card1.card_data == card2.card_data:
		await get_tree().create_timer(0.4).timeout

		var index1 = card1.grid_index
		var index2 = card2.grid_index

		move_to_match_area(card1)
		move_to_match_area(card2)

		draw_card_from_pile(index1)
		draw_card_from_pile(index2)
	else:
		await get_tree().create_timer(0.8).timeout
		card1.force_flip()
		card2.force_flip()

	flipped_cards.clear()
	checking_match = false
	unlock_all_cards()

func move_to_match_area(card):
	card.get_parent().remove_child(card)
	match_slots.add_child(card)

	var offset = Vector2(0, 0)
	card.position = offset * match_slots.get_child_count()
	card.is_reversible = false

func lock_all_cards():
	for card in get_tree().get_nodes_in_group("memory_cards"):
		card.can_flip = false

func unlock_all_cards():
	for card in get_tree().get_nodes_in_group("memory_cards"):
		card.can_flip = true

func draw_card_from_pile(index):
	if draw_pile.get_child_count() == 0:
		return
	
	var new_card = draw_pile.get_child(0)
	draw_pile.remove_child(new_card)
	grid.add_child(new_card)

	new_card.grid_index = index
	new_card.position = get_grid_position(index)
	new_card.set_face_down()
	new_card.is_reversible = true
	
	update_draw_pile_label()

func get_grid_position(index):
	var cols = 7
	var spacing = Vector2(160, 160)

	var row = index / cols
	var col = index % cols

	return Vector2(
		col * spacing.x,
		row * spacing.y
	)

func update_draw_pile_label():
	draw_pile_label.text = "(" + str(draw_pile.get_child_count()) + ")"
