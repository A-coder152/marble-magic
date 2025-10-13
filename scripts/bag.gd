extends Control

@onready var marbles_container = $ScrollContainer/VBoxContainer/HBoxContainer

var marble_bag_scene = preload("res://scenes/bag_item.tscn")

var marbles_listed = []
var in_shop = false
var counter = 1
var since_last_change = 0

func _ready() -> void:
	since_last_change = 0
	counter = 0
	var marble_containers = [$ScrollContainer/VBoxContainer/HBoxContainer, $ScrollContainer/VBoxContainer/HBoxContainer2, $ScrollContainer/VBoxContainer/HBoxContainer3, $ScrollContainer/VBoxContainer/HBoxContainer4]
	marbles_container = marble_containers[counter]
	marbles_listed = []
	for container in marble_containers:
		for child in container.get_children():
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
			since_last_change += 1
		if since_last_change >= 6:
			print(marbles_container.get_children())
			var old_marbles_container = marbles_container
			counter += 1
			marbles_container = marble_containers[counter]
			print(marbles_container == old_marbles_container)
			since_last_change = 0


func _on_close_button_pressed() -> void:
	GameManager.close_bag.emit()
