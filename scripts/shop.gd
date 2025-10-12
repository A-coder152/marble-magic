extends Control

@onready var cont_1 = $HBoxContainer/VBoxContainer/cont1
@onready var cont_2 = $HBoxContainer/VBoxContainer/cont2
@onready var coins_label = $coins
@onready var Bag = $Bag

var marble_bag_scene = preload("res://scenes/bag_item.tscn")

var marbles_chosen = []

func _ready() -> void:
	GameManager.refresh_shop.connect(run_shop)
	GameManager.close_bag.connect(close_bag)
	run_shop()
	
func run_shop():
	if Bag.visible: Bag._ready()
	clear_children(cont_1)
	clear_children(cont_2)
	coins_label.text = "Coins: " + str(GameManager.coins) 
	print("tararaal ", GameManager.coins)
	while len(marbles_chosen) < 6:
		var random_marble = GameManager.all_marbles[randi_range(0, len(GameManager.all_marbles) -1)]
		if random_marble not in marbles_chosen: marbles_chosen.append(random_marble)
	for marble in marbles_chosen:
		var new_marble = marble_bag_scene.instantiate()
		new_marble.in_shop = true
		new_marble.marble_assigned = marble
		new_marble._ready()
		new_marble.setup_marble()
		new_marble.scale = Vector2(4/3., 4/3.)
		new_marble.custom_minimum_size = Vector2(200, 200)
		if marbles_chosen.find(marble) < 3:
			cont_1.add_child(new_marble)
		else:
			cont_2.add_child(new_marble)

func clear_children(node):
	for child in node.get_children():
		child.queue_free()

func _on_close_button_pressed() -> void:
	GameManager.close_shop.emit()

func update_coins_label():
	coins_label.text = str(GameManager.coins)

func _on_bag_btn_pressed() -> void:
	Bag.in_shop = true
	Bag.visible = true
	Bag._ready()
	$bgalpha.visible = true

func close_bag():
	Bag.visible = false
	$bgalpha.visible = false
