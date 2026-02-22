extends Node2D


@export var stamina := 10
@export var lives := 3
@export var score := 0

@export var card_scene: PackedScene
@export var all_card_data: Array[CardData]

@onready var grid = $GridContainer
@onready var draw_pile = $DrawPile
@onready var draw_pile_label = $UIElements/DrawPileCount
@onready var failure_game = $EndScreen/FailureGame
@onready var StartGame = $StartGame
@onready var anim = $IntroAnimation

var flipped_cards: Array = []
var checking_match := false

@onready var match_slots = $MatchedPile
@onready var slots = $InventoryUI/Slots

func _ready():
	anim.play("StartGame")
	StartGame.play()
	failure_game.visible = false
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
		failure_game.visible = true
		 # Game over, add gameover func later 
	print("Number of lives")
	print(lives)
	print("Stamina")
	print(stamina)

func shuffle_and_deal():
	for child in grid.get_children():
		child.queue_free()
	for child in draw_pile.get_children():
		child.queue_free()

	var deck = all_card_data.duplicate()
	# deck size = 32
	deck.shuffle()

	var grid_cards = deck.slice(0, 21)

	var pile_cards = deck.slice(21, deck.size())

	deal_grid(grid_cards)
	deal_pile(pile_cards)

# This function will return the next available slot in the inventory
# For example, if slot 1 and 2 are taken, it will return slot 3
# if all slots are taken, it will return an emtpy slot
func next_slot():
	for slot in slots.get_children():
		if slot.get_child_count() == 0:
			return slot
	return null
			
func deal_grid(cards):
	var rows = 3
	var cols = 7
	var spacing = Vector2(160, 160)
	
	# cards.size = 21
	for i in range(cards.size()):
		var row = i / cols # 1/21
		var col = i % cols # 1
	
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
	update_stamina(-1)
	print("Updated stamina")
	print(stamina)

	if checking_match:
		return

	if not card.is_face_up:
		return

	flipped_cards.append(card)

	if flipped_cards.size() == 2:
		checking_match = true
		lock_all_cards()
		check_match()

func update_stamina(value):
	if stamina + value <= 10:
		stamina = stamina + value
	if stamina == 0:
		lose_a_life()
		stamina = 10
	
func check_match():
	var card1 = flipped_cards[0]
	var card2 = flipped_cards[1]

	if card1.card_data == card2.card_data:
		await get_tree().create_timer(0.4).timeout

		var index1 = card1.grid_index
		var index2 = card2.grid_index

		move_to_inventory([card1,index1],[card2,index2])
		
		update_stamina(3)
		print("Update stamina")
		print(stamina)
		
		#move_to_match_area(card1)
		#move_to_match_area(card2)
	else:
		await get_tree().create_timer(0.8).timeout
		card1.force_flip()
		card2.force_flip()

	flipped_cards.clear()
	checking_match = false
	
	if next_slot() == null:
		lock_all_cards()
	else:
		unlock_all_cards()
	
func move_to_inventory(card1,card2):
	var next_slot = next_slot();
	card1[0].get_parent().remove_child(card1[0])
	card2[0].get_parent().remove_child(card2[0])
			
	next_slot.add_child(card1[0])	
	card1[0].position = Vector2(68,85)
			
	draw_card_from_pile(card1[1])
	draw_card_from_pile(card2[1])
			
	card2[0].queue_free()
	
	#card.new_parent(slot).add_child(card)

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
