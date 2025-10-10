extends Control

@onready var bg_node = $BG
@onready var button = $Button
@onready var count_label = $Count

var marble_assigned

func _ready() -> void:
	pass
	
func setup_marble():
	var count = 0
	for marble in GameManager.marble_values:
		if marble == marble_assigned:
			count += 1
	count_label.text = count
