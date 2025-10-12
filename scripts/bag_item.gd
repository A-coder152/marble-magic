extends Control

@onready var bg_node = $BG
@onready var button = $Button
@onready var count_label = $Count

var marble_assigned: Marble
var in_shop = false

func _ready() -> void:
	print("yoooo")
	
func setup_marble():
	var count = 0
	for marble in GameManager.bag_marbles:
		if GameManager.all_marbles[marble] == marble_assigned:
			count += 1
	count_label.text = str(count)
	button.text = marble_assigned.temp_bag_title
	button.tooltip_text = marble_assigned.title + ": " + marble_assigned.description
