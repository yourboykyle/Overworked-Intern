@tool
extends Node2D

@export var card_data: CardData
@export var is_face_up := true
@export var in_deck := true

@onready var front = $Front
@onready var back = $Back

func _ready():
	apply_card_data()
	update_visual()

func apply_card_data():
	if card_data:
		front.texture = card_data.front_texture
		back.texture = card_data.back_texture

func flip():
	is_face_up = !is_face_up
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
