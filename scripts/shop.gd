extends Control

@onready var cont_1 = $HBoxContainer/VBoxContainer/cont1
@onready var cont_2 = $HBoxContainer/VBoxContainer/cont2

var marble_bag_scene = preload("res://scenes/bag_item.tscn")

var marbles_chosen = []

func _ready() -> void:
	while len(marbles_chosen) < 6:
		var random_marble = GameManager.all_marbles[randi_range(0, len(GameManager.all_marbles) -1)]
		if random_marble not in marbles_chosen: marbles_chosen.append(random_marble)
	for marble in marbles_chosen:
		var new_marble = marble_bag_scene.instantiate()
		new_marble._ready()
		new_marble.marble_assigned = marble
		new_marble.setup_marble()
		new_marble.scale = Vector2(4/3., 4/3.)
		new_marble.custom_minimum_size = Vector2(200, 200)
		if len(cont_1.get_children()) < 3:
			cont_1.add_child(new_marble)
		else:
			cont_2.add_child(new_marble)


func _on_close_button_pressed() -> void:
	GameManager.close_bag.emit()
