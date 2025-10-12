extends Control

@onready var bg_node = $BG
@onready var button = $Button
@onready var count_label = $Count
@onready var cost_label = $Cost

var marble_assigned: Marble
var in_shop = false
var shop_bag = false

func _ready() -> void:
	print("yoooo")
	
func setup_marble():
	if in_shop:
		cost_label.text = str(marble_assigned.cost)
		cost_label.visible = true
		button.pressed.connect(buy_marble)
	elif shop_bag:
		cost_label.text = str(marble_assigned.cost - 1)
		cost_label.visible = true
		button.pressed.connect(sell_marble)
	button.texture_normal = marble_assigned.texture
	var count = 0
	for marble in GameManager.bag_marbles:
		if GameManager.all_marbles[marble] == marble_assigned:
			count += 1
	count_label.text = str(count)
	#button.text = marble_assigned.temp_bag_title
	button.tooltip_text = marble_assigned.title + ": " + marble_assigned.description

func buy_marble():
	if GameManager.coins >= marble_assigned.cost:
		GameManager.bag_marbles.append(GameManager.all_marbles.find(marble_assigned))
		GameManager.coins -= marble_assigned.cost
	GameManager.refresh_shop.emit()

func sell_marble():
	GameManager.bag_marbles.erase(GameManager.all_marbles.find(marble_assigned))
	GameManager.coins += int(cost_label.text)
	GameManager.refresh_shop.emit()
