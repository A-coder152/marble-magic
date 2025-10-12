extends Control

@onready var marbles_container = $ScrollContainer/VBoxContainer/HBoxContainer

var marble_bag_scene = preload("res://scenes/bag_item.tscn")

var marbles_listed = []
var in_shop = false

func _ready() -> void:
	marbles_listed = []
	for child in marbles_container.get_children():
		child.queue_free()
	for marble_idx in GameManager.bag_marbles:
		var marble = GameManager.all_marbles[marble_idx]
		if marble not in marbles_listed:
			print(marble_idx)
			var new_marble = marble_bag_scene.instantiate()
			new_marble._ready()
			new_marble.shop_bag = in_shop
			new_marble.marble_assigned = marble
			new_marble.setup_marble()
			marbles_listed.append(marble)
			marbles_container.add_child(new_marble)


func _on_close_button_pressed() -> void:
	GameManager.close_bag.emit()
