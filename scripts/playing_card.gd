@tool
extends Node2D

signal card_flipped(card)

@export var card_data: CardData
@export var is_face_up := true
@export var in_deck := true
@export var is_reversible := true

@onready var front = $Front
@onready var back = $Back

@export var can_flip := true

var grid_index: int = -1

func _ready():
	apply_card_data()
	update_visual()


func apply_card_data():
	if card_data:
		front.texture = card_data.front_texture
		back.texture = card_data.back_texture

func flip():
	if not is_reversible or not can_flip:
		return

	is_face_up = !is_face_up
	update_visual()
	emit_signal("card_flipped", self)

func force_flip():
	is_face_up = !is_face_up
	update_visual()

func set_face_up():
	is_face_up = true
	update_visual()

func set_face_down():
	is_face_up = false
	update_visual()

func update_visual():
	front.visible = is_face_up
	back.visible = !is_face_up


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		flip()

func _process(_delta):
	if Engine.is_editor_hint():
		apply_card_data()
		update_visual()
