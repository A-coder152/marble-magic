# GameScene.gd
extends Control

@onready var player_health_bar = $PlayerHealthBar
@onready var enemy_health_bar = $EnemyHealthBar
@onready var message_label = $MessageLabel
@onready var marble_container = $MarbleContainer
@onready var confirm_button = $ConfirmButton
@onready var bgalpha = $BGAlpha
@onready var Shop = $Shop
@onready var Bag = $Bag
@onready var bgbeta = $BGBeta

var marble_instances: Array = [] 

var enemy_textures = [
	preload("res://images/enemy1.png"),
	preload("res://images/enemy2.png"),
	preload("res://images/enemy3.png")
]
var enemy_on = 2

func _ready():
	_setup_marbles()
	_connect_signals()
	_update_ui_for_phase(GameManager.current_turn_phase)

func _setup_marbles():
	var marble_scene = preload("res://scenes/marble.tscn") 

	for i in range(4):
		var marble_instance = marble_scene.instantiate()
		marble_container.add_child(marble_instance)
		marble_instances.append(marble_instance)
		marble_instance.set_marble_data(i)
		marble_instance.marble_clicked.connect(GameManager.handle_marble_selection)

func _connect_signals():
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.turn_phase_changed.connect(_on_turn_phase_changed)
	GameManager.marble_selected.connect(_on_marble_selected)
	#GameManager.damage_dealt.connect(_on_damage_dealt)
	GameManager.game_over.connect(_on_game_over)
	confirm_button.pressed.connect(GameManager.confirm_selection)
	GameManager.close_bag.connect(close_bag)
	GameManager.close_shop.connect(close_shop)
	GameManager.change_coins.connect(change_coins)
	GameManager.change_stunned.connect(change_stunned)


func _on_health_changed(entity_type: String, current_hp: int, max_hp: int):
	if entity_type == "player":
		player_health_bar.max_value = max_hp
		player_health_bar.value = current_hp
	elif entity_type == "enemy":
		enemy_health_bar.max_value = max_hp
		enemy_health_bar.value = current_hp

func _on_turn_phase_changed(new_phase: int):
	_update_ui_for_phase(new_phase)

func _on_marble_selected(_index: int):
	for i in range(marble_instances.size()):
		var marble = marble_instances[i]
		var is_selected = GameManager.selected_marble_indices.has(i)
		marble.set_selected(is_selected)

#func _on_damage_dealt(amount: int, target: String):
	#print("UI: %d damage dealt to %s!" % [amount, target])

func _on_game_over(win: bool):
	confirm_button.disabled = true
	$BGAlpha.visible = true
	if win:
		message_label.text = "GAME OVER! YOU WIN!"
		$RoundWonPopup.visible = true
	else:
		message_label.text = "GAME OVER! YOU LOST!"
		$RoundLostPopup.visible = true

func _update_ui_for_phase(phase: int):
	match phase:
		GameManager.TurnPhase.TAKE_1_SELECTION:
			bgbeta.visible = true
			message_label.text = "Choose 2 marbles for Take 1 (Damage Preview)."
			confirm_button.text = "Confirm Take 1 Selection"
			confirm_button.disabled = false
			_update_marble_values_and_visibility(false)
			_reset_marble_selection_visuals()
			
		GameManager.TurnPhase.TAKE_1_REVEAL:
			message_label.text = "Potential Damage: %d" % GameManager.potential_damage
			confirm_button.disabled = true
			_update_marble_values_and_visibility(false)
			_reset_marble_selection_visuals()
			
		GameManager.TurnPhase.TAKE_2_SELECTION:
			bgbeta.visible = false
			message_label.text = "Choose 2 marbles for Take 2 (Actual Damage)."
			confirm_button.text = "Confirm Take 2 Selection"
			confirm_button.disabled = false
			_update_marble_values_and_visibility(false)
			_reset_marble_selection_visuals()
			
		GameManager.TurnPhase.TURN_END:
			confirm_button.disabled = true
			_update_marble_values_and_visibility(true)
			_reset_marble_selection_visuals()
			message_label.text = "Turn ended. Enemy attacking..." 
			if enemy_health_bar.value <= 0: 
				message_label.text = "Enemy defeated! Starting next round..."
				GameManager.coins += 5
				change_coins()


func _update_marble_values_and_visibility(reveal_all: bool):
	for i in range(marble_instances.size()):
		var marble = marble_instances[i]
		if i < GameManager.current_marbles.size():
			marble.set_marble_data(i, GameManager.current_marbles[i])
		marble.reveal_value(reveal_all)

func _reset_marble_selection_visuals():
	for marble in marble_instances:
		marble.set_selected(false)

func _on_round_won_pressed() -> void:
	$Enemy.texture = enemy_textures[enemy_on]
	enemy_on = (enemy_on + 1) % 3
	GameManager.start_new_game()
	bgalpha.visible = false
	$RoundWonPopup.visible = false

func _on_round_lost_game_pressed() -> void:
	GameManager.start_new_game()
	bgalpha.visible = false
	$RoundLostPopup.visible = false

func _on_reset_game_pressed() -> void:
	GameManager.enemy_max_health = 5
	GameManager.enemy_max_dmg = 2
	GameManager.coins = 0
	GameManager.bag_marbles = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
	$Enemy.texture = preload("res://images/enemy2.png")
	enemy_on = 2
	_on_round_lost_game_pressed()

func _on_bag_btn_pressed() -> void:
	Bag.visible = true
	Bag._ready()
	bgalpha.visible = true

func close_bag():
	Bag.visible = false
	bgalpha.visible = false

func _on_shop_pressed() -> void:
	Shop.visible = true
	Shop.run_shop()

func close_shop():
	Shop.visible = false
	bgalpha.visible = true
	change_coins()

func change_coins():
	$coins.text = str(GameManager.coins)

func change_stunned():
	$Stunned.visible = true if !$Stunned.visible else false


func _on_button_pressed() -> void:
	$Lore.hide()


func _on_button_tutorial_pressed() -> void:
	$Tutorial.hide()
