# GameManager.gd
extends Node

# --- Game State Variables ---
var player_health: int = 20
var enemy_health: int = 20
var player_max_health: int = 25 # Max health for both player and enemy
var enemy_max_health: int = 5
var enemy_max_dmg: int = 2

# Marbles: An array to store the current attack values of the 4 marbles
# We'll populate this with random values at the start of each turn.
var current_marbles: Array = [] # e.g., [12, 8, 15, 7]

# Selection: Store the indices of the marbles currently selected by the player
var selected_marble_indices: Array = [] # e.g., [0, 3] for the first and fourth marble

# Turn Phases: Define an enum for clear state management
enum TurnPhase {
	TAKE_1_SELECTION,    # Player chooses 2 marbles for preview
	TAKE_1_REVEAL,       # Display potential damage
	TAKE_2_SELECTION,    # Player chooses 2 marbles for actual damage
	TURN_END,            # Apply damage, check game over, prepare next turn
	GAME_OVER            # Game has ended (win/lose)
}
var current_turn_phase: int = TurnPhase.TAKE_1_SELECTION

var potential_damage: int = 0 # Damage calculated in Take 1
var marble_values: Array = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5]

# --- Signals (to notify other parts of the game) ---
# Emitted when a marble is clicked/selected
signal marble_selected(index: int)
# Emitted when the player confirms their selection
signal selection_confirmed()
# Emitted when the turn phase changes
signal turn_phase_changed(new_phase: int)
# Emitted when health changes (for UI updates)
signal health_changed(entity_type: String, current_hp: int, max_hp: int)
# Emitted when damage is dealt
signal damage_dealt(amount: int, target: String)
# Emitted when game over state is reached
signal game_over(win: bool)

# --- Core Functions ---

# Called when the node enters the scene tree for the first time.
func _ready():
	print("GameManager ready and loaded!")
	start_new_game()
	
func start_next_turn():
	_generate_new_marbles()
	selected_marble_indices.clear()
	potential_damage = 0
	_set_turn_phase(TurnPhase.TAKE_1_SELECTION)
	# Emit initial health signals
	health_changed.emit("player", player_health, player_max_health)
	health_changed.emit("enemy", enemy_health, enemy_max_health)
	

# Initializes a new game or resets for a new round
func start_new_game():
	enemy_max_health += 5
	enemy_max_dmg += 1
	player_health = player_max_health
	enemy_health = enemy_max_health 
	start_next_turn()

# Generates new random values for the marbles
func _generate_new_marbles():
	current_marbles.clear()
	for i in range(4): # 4 marbles
		current_marbles.append(marble_values[randi_range(0, len(marble_values) - 1)]) # Random value between 5 and 20
	print("New marbles generated: ", current_marbles)

# Handles a marble being selected/deselected
func handle_marble_selection(index: int):
	if current_turn_phase == TurnPhase.TAKE_1_SELECTION or \
	   current_turn_phase == TurnPhase.TAKE_2_SELECTION:
		if selected_marble_indices.has(index):
			selected_marble_indices.erase(index)
		else:
			if selected_marble_indices.size() < 2:
				selected_marble_indices.append(index)
			else:
				# Replace the oldest selection if 2 are already chosen
				selected_marble_indices.pop_front()
				selected_marble_indices.append(index)
		print("Selected marbles: ", selected_marble_indices)
		marble_selected.emit(index) # Emit signal for UI to update marble state

# Handles the player confirming their marble selection
func confirm_selection():
	if selected_marble_indices.size() != 2:
		print("Please select exactly 2 marbles.")
		return

	var chosen_values = []
	for index in selected_marble_indices:
		chosen_values.append(current_marbles[index])

	var total_chosen_damage = chosen_values[0] + chosen_values[1]

	if current_turn_phase == TurnPhase.TAKE_1_SELECTION:
		potential_damage = total_chosen_damage
		print("Take 1 Potential Damage: ", potential_damage)
		_set_turn_phase(TurnPhase.TAKE_1_REVEAL) # Briefly show potential damage
		# Transition to next phase after a short delay
		get_tree().create_timer(1.5).timeout.connect(func():
			_set_turn_phase(TurnPhase.TAKE_2_SELECTION)
			selected_marble_indices.clear() # Clear selection for next phase
		)
	elif current_turn_phase == TurnPhase.TAKE_2_SELECTION:
		print("Take 2 Actual Damage: ", total_chosen_damage)
		_apply_damage_to_enemy(total_chosen_damage)
		_set_turn_phase(TurnPhase.TURN_END)
		# After a short delay, proceed to next turn or game over check
		get_tree().create_timer(1.5).timeout.connect(func():
			_end_turn()
		)

# Applies damage to the enemy
func _apply_damage_to_enemy(amount: int):
	enemy_health = max(0, enemy_health - amount)
	print("Enemy health after damage: ", enemy_health)
	health_changed.emit("enemy", enemy_health, enemy_max_health)
	damage_dealt.emit(amount, "enemy")

# Simulates enemy's turn and applies damage to player
func _enemy_turn():
	var enemy_damage = randi_range(1, enemy_max_dmg) # Random damage for enemy
	player_health = max(0, player_health - enemy_damage)
	print("Player health after enemy attack: ", player_health)
	health_changed.emit("player", player_health, player_max_health)
	damage_dealt.emit(enemy_damage, "player")

# Handles the end of a turn, checks game over, or prepares next turn
func _end_turn():
	if player_health <= 0:
		_set_turn_phase(TurnPhase.GAME_OVER)
		game_over.emit(false) # Player lost
		print("Game Over! You lost.")
		start_new_game()
	elif enemy_health <= 0:
		_set_turn_phase(TurnPhase.GAME_OVER)
		game_over.emit(true) # Player won
		print("Game Over! You won!")
		start_new_game()
	else:
		# If game not over, start next turn
		_enemy_turn() # Enemy attacks before new turn starts
		# Check game over again after enemy attack
		if player_health <= 0:
			_set_turn_phase(TurnPhase.GAME_OVER)
			game_over.emit(false) # Player lost
			print("Game Over! You lost after enemy attack.")
			start_new_game()
		else:
			print("Starting new turn...")
			start_next_turn() # Resets marbles and phase

# Helper function to change and emit the turn phase
func _set_turn_phase(new_phase: int):
	current_turn_phase = new_phase
	turn_phase_changed.emit(new_phase)
	print("Turn Phase: ", TurnPhase.keys()[new_phase])
