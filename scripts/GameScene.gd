# GameScene.gd
extends Control

@onready var player_health_bar = $PlayerHealthBar
@onready var enemy_health_bar = $EnemyHealthBar
@onready var message_label = $MessageLabel
@onready var marble_container = $MarbleContainer
@onready var confirm_button = $ConfirmButton

var marble_instances: Array = [] # To hold references to our instantiated marble nodes

func _ready():
	# Ensure GameManager is ready (it's an Autoload, so it should be)
	print("GameScene ready!")

	_setup_marbles()
	_connect_signals()
	_update_ui_for_phase(GameManager.current_turn_phase) # Initial UI setup

# --- Setup Functions ---

func _setup_marbles():
	# Load the Marble scene
	var marble_scene = preload("res://scenes/marble.tscn") # Adjust path if different

	# Instantiate 4 marbles and add them to the container
	for i in range(4):
		var marble_instance = marble_scene.instantiate()
		marble_container.add_child(marble_instance)
		marble_instances.append(marble_instance)
		# Set initial data and connect its click signal to GameManager
		marble_instance.set_marble_data(i, 0) # Value will be updated by GameManager
		marble_instance.marble_clicked.connect(GameManager.handle_marble_selection)

# Connects signals from GameManager to this scene's functions
func _connect_signals():
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.turn_phase_changed.connect(_on_turn_phase_changed)
	GameManager.marble_selected.connect(_on_marble_selected)
	GameManager.damage_dealt.connect(_on_damage_dealt)
	GameManager.game_over.connect(_on_game_over)

	# Connect UI elements to GameManager
	confirm_button.pressed.connect(GameManager.confirm_selection)

# --- Signal Callbacks from GameManager ---

func _on_health_changed(entity_type: String, current_hp: int, max_hp: int):
	if entity_type == "player":
		player_health_bar.max_value = max_hp
		player_health_bar.value = current_hp
	elif entity_type == "enemy":
		enemy_health_bar.max_value = max_hp
		enemy_health_bar.value = current_hp

func _on_turn_phase_changed(new_phase: int):
	_update_ui_for_phase(new_phase)

func _on_marble_selected(index: int):
	# Update selection visual for all marbles
	for i in range(marble_instances.size()):
		var marble = marble_instances[i]
		# Check if this marble's index is in GameManager's selected_marble_indices
		var is_selected = GameManager.selected_marble_indices.has(i)
		marble.set_selected(is_selected)

func _on_damage_dealt(amount: int, target: String):
	# Optional: Add visual feedback for damage dealt (e.g., pop-up text)
	print("UI: %d damage dealt to %s!" % [amount, target])

func _on_game_over(win: bool):
	confirm_button.disabled = true
	$BGAlpha.visible = true
	if win:
		message_label.text = "GAME OVER! YOU WIN!"
		$RoundWonPopup.visible = true
	else:
		message_label.text = "GAME OVER! YOU LOST!"
		$RoundLostPopup.visible = true
	# You might want to show a "Play Again" button here

# --- UI Update Logic based on Turn Phase ---

func _update_ui_for_phase(phase: int):
	match phase:
		GameManager.TurnPhase.TAKE_1_SELECTION:
			message_label.text = "Choose 2 marbles for Take 1 (Damage Preview)."
			confirm_button.text = "Confirm Take 1 Selection"
			confirm_button.disabled = false
			_update_marble_values_and_visibility(false) # Hide values
			_reset_marble_selection_visuals()
		GameManager.TurnPhase.TAKE_1_REVEAL:
			message_label.text = "Potential Damage: %d" % GameManager.potential_damage
			confirm_button.disabled = true # Disable during reveal
			_update_marble_values_and_visibility(false) # Still hidden for now
			_reset_marble_selection_visuals() # Clear selection visuals
		GameManager.TurnPhase.TAKE_2_SELECTION:
			message_label.text = "Choose 2 marbles for Take 2 (Actual Damage)."
			confirm_button.text = "Confirm Take 2 Selection"
			confirm_button.disabled = false
			_update_marble_values_and_visibility(false) # Still hidden
			_reset_marble_selection_visuals() # Clear selection visuals
		GameManager.TurnPhase.TURN_END:
			confirm_button.disabled = true
			_update_marble_values_and_visibility(true) # Reveal all marbles at turn end
			_reset_marble_selection_visuals() # Clear selection visuals
			message_label.text = "Turn ended. Enemy attacking..." if enemy_health_bar.value > 0 else "Enemy defeated! Starting next round..."
		GameManager.TurnPhase.GAME_OVER:
			# Handled by _on_game_over signal
			pass

# Helper to update marble values and their visibility
func _update_marble_values_and_visibility(reveal_all: bool):
	for i in range(marble_instances.size()):
		var marble = marble_instances[i]
		# Update the marble's internal value from GameManager
		if i < GameManager.current_marbles.size():
			marble.set_marble_data(i, GameManager.current_marbles[i])
		marble.reveal_value(reveal_all)

# Helper to reset selection visuals for all marbles
func _reset_marble_selection_visuals():
	for marble in marble_instances:
		marble.set_selected(false)


func _on_round_won_pressed() -> void:
	GameManager.start_new_game()
	$BGAlpha.visible = false
	$RoundWonPopup.visible = false


func _on_round_lost_game_pressed() -> void:
	GameManager.start_new_game()
	$BGAlpha.visible = false
	$RoundLostPopup.visible = false


func _on_reset_game_pressed() -> void:
	GameManager.enemy_max_health = 5
	GameManager.enemy_max_dmg = 2
	_on_round_lost_game_pressed()
